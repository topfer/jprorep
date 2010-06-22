#!/usr/bin/perl -w

use Switch;
use Net::LDAP;
use URI::Escape;
use CGI qw(:standard escapeHTML);

require "base.pl";

my ($actualDN, $updateJSTree);

#open(CGILOG, ">> /tmp/cgi.log");

#creates a "(key1, value, key2, value2)" like list that i slater used to update LDAP entries 
sub createListfromCGIParams {
    my (@replaceList, $srcListRef);

    if ( param("objectClass") eq "propertyObject") {
        $srcListRef = $propertyAttrs;
    } elsif ( param("objectClass") eq "propertyContainer") {
        $srcListRef = $containerAttrs;
    }     

    foreach $attr (@$srcListRef) {
        if ( length param($attr) > 0) {
            push(@replaceList, $attr ,param($attr));
        }
    }

    return \@replaceList;
}

#creates a "(key1, value, key2, value2)" like list that i slater used to update LDAP entries 
sub createParamListByCopy {

    my (@replaceList, $sourceDN, $sourceEntry, $attrList);
    $sourceDN = $_[0];
    
    $sourceEntry = getLDAPEntry(param("nodeDN"));

    if ( $sourceEntry->get_value("objectclass") eq "propertyObject") {
        $attrList = $propertyAttrs;
    } elsif ( $sourceEntry->get_value("objectclass") eq "propertyContainer") {
        $attrList = $containerAttrs;
    }

    foreach $attr (@$attrList) {    
        push(@replaceList, $attr ,$sourceEntry->get_value($attr));
    }

    return \@replaceList;
}

sub LDAPcreateUsingList {
   my ($ldap, $dn, $whatToChange ) = @_;
   my $result = $ldap->add ( $dn,
                                changes => [
                                  replace => [ @$whatToChange ]
                                ]
                              );
   return $result;
}

sub LDAPmodifyUsingList {
   my ($ldap, $dn, $whatToChange ) = @_;
   my $result = $ldap->modify ( $dn,
                                changes => [
                                  replace => [ @$whatToChange ]
                                ]
                              );
   return $result;
}

sub setContainerChildCount {
    my ($parentDN, $step) = @_;

    my $parentEntry = &getLDAPEntry($parentDN);
    my $childrenCount = $parentEntry->get_value( "childrenCount" );            

    if ( ! $childrenCount ) {
        $childrenCount = 0;
    }

    @paramList = ("childrenCount", $childrenCount + $step);

    $result = $ldap->modify($parentDN, changes => [ replace => [ @paramList ] ]);

    return $result;
}

$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

$result = $ldap->bind("cn=Manager,dc=arcore,dc=amadeus,dc=com", password => "secret");
die $result->error(  ) if $result->code(  );


switch ( param("predicate") ) {

    case "create" {
        my $parentDN = param("nodeDN");
        $actualDN = "cn=".param("cn").",".param("nodeDN");

        my $translationList = &createListfromCGIParams();

        push(@$translationList, "objectclass", param("objectClass"));

        $result = $ldap->add($actualDN, attr => $translationList);

        #if creation was successul increment child count of the parent
        if ( !$result->code ) {
            $result = &setContainerChildCount($parentDN, 1);
        }
        
        $updateJSTree = "&updateJSTree=create&objectType=".param("objectClass");
    }

    case "link" {
        my ($containingDN, $currentCN, @translationList);

        if ( param("nodePosType") eq "inside" ) {
            $containingDN = param("refnodeDN");
        } else {
            $containingDN = substr(param("refnodeDN"), index(param("refnodeDN"),',') + 1);
        }    

        $currentCN = substr(param("nodeDN"), 0, index(param("nodeDN"), ','));
        $actualDN = $currentCN.','.$containingDN;
        
        push(@translationList, "objectclass", "alias");
        push(@translationList, "objectclass", "extensibleObject");
        push(@translationList, "aliasedObjectName", param("nodeDN"));

        $result = $ldap->add($actualDN, attr => \@translationList);

        #if creation of link was successul increment child count of the parent
        if ( !$result->code ) {
            $result = &setContainerChildCount($containingDN, 1);
        }

        $updateJSTree = "&updateJSTree=link";
    }

    case "copy" {
        my ($sourceEntry, $attrList, $containingDN, $currentCN, $translationListRef);

        if ( param("nodePosType") eq "inside" ) {
            $containingDN = param("refnodeDN");
        } else {
            $containingDN = substr(param("refnodeDN"), index(param("refnodeDN"),',') + 1);
        }    

        $currentCN = substr(param("nodeDN"), 0, index(param("nodeDN"), ','));
        $actualDN = $currentCN.','.$containingDN;
        
        $translationListRef = &createParamListByCopy(param("nodeDN"));    

        push(@$translationListRef, "objectclass", "propertyObject");

        $result = $ldap->add($actualDN, attr => $translationListRef);

        #if creation was successul increment child count of the parent
        if ( !$result->code ) {
            $result = &setContainerChildCount($containingDN, 1);
        }

        $updateJSTree = "&updateJSTree=create&objectType=propertyObject";
    }

    case "move" {
        my ($sourceEntry, $attrList, $containingDN, $currentCN, $translationListRef);

        if ( param("nodePosType") eq "inside" ) {
            $containingDN = param("refnodeDN");
        } else {
            $containingDN = substr(param("refnodeDN"), index(param("refnodeDN"),',') + 1);
        }    

        $currentCN = substr(param("nodeDN"), 0, index(param("nodeDN"), ','));
        $actualDN = $currentCN.','.$containingDN;
        
        $translationListRef = &createParamListByCopy(param("nodeDN"));    

        push(@$translationListRef, "objectclass", "propertyObject");

        $result = $ldap->add($actualDN, attr => $translationListRef);

        #if creation was successul increment child count of the parent
        if ( !$result->code ) {
            $result = &setContainerChildCount($containingDN, 1);
        }

        $result = $ldap->delete(param("nodeDN"));

        #if removal was successul decrement child count of the parent
        if ( !$result->code ) {
            my $parentDN = substr(param("nodeDN"), index(param("nodeDN"), ',') + 1);
            $result = &setContainerChildCount($parentDN, -1);
        }

        $updateJSTree = "&updateJSTree=move&objectType=propertyObject";
    }

    case "update" {
        my $translationList = &createListfromCGIParams();

        $actualDN = param("nodeDN");

        $"='.';

        $result = $ldap->modify(param("nodeDN"), changes => [ replace => [ @$translationList ] ]);
        $updateJSTree = "&updateJSTree=update";        
    }

    case "remove" {    
        my $myNodeDN = param("nodeDN");
        $result = $ldap->delete($myNodeDN);

        #if removal was successul decrement child count of the parent
        if ( !$result->code ) {
            my $parentDN = substr($myNodeDN, index($myNodeDN, ',') + 1);
            $result = &setContainerChildCount($parentDN, -1);
        }

        $updateJSTree = "&updateJSTree=remove";
    }

    else {
        my $ldapMessageObject = Net::LDAP::message->new();

        

#         $result = {
#             "code" => 9999;
#             "error_name" => "Unknown LDAP action";
#             "error_text" => "Unknown LDAP action requested [".param("predicate")."]";
#             "mesg_id" => 9999;
#             "dn" = param("nodeDN");
#         }

        $result = \$ldapMessageObject;
        
    }
}

if ( $result->code ) {
    print "Content-type: text/html\r\n\r\n";
    print "<html><body>\n";
    print "Return code: ".$result->code."<br/>\n";
    print "Message: ".$result->error_name."<br/>\n";
    print "Message text : ".$result->error_text."<br/>\n";
    print "MessageID: ".$result->mesg_id."<br/>\n";
    print "DN: ".$result->dn."<br/>\n";
    print "</body></html>\n";
    die $result->error;
}

$ldap->unbind;

#print CGILOG "Status: 302 Moved\nLocation:"."details.pl?nodeDN=".uri_escape($actualDN."&tab=details&predicate=view")."\n\n";
print "Status: 302 Moved\nLocation:"."details.pl?nodeDN=".uri_escape($actualDN)."&tab=details&predicate=view".$updateJSTree."\n\n";

