#!/usr/bin/perl -w
use Net::LDAP;
use URI::Escape;
use CGI qw(:standard escapeHTML);

require "base.pl";

my ($actualDN, $updateJSTree);

#open(CGILOG, ">> /tmp/cgi.log");

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

$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

$result = $ldap->bind("cn=Manager,dc=arcore,dc=amadeus,dc=com", password => "secret");
die $result->error(  ) if $result->code(  );

if ( param("predicate") eq "create") {

    $actualDN = "cn=".param("cn").",".param("nodeDN");

    my $translationList = &createListfromCGIParams();

    push(@$translationList, "objectclass", param("objectClass"));

    $result = $ldap->add($actualDN, attr => $translationList);
    $updateJSTree = "&updateJSTree=add";

} elsif ( param("predicate") eq "link") {

    my ($containingDN, $currentCN, @translationList);

    if ( param("nodePosType") eq "inside" ) {
        $containingDN = param("refnodeDN");
    } else {
        $containingDN = substr(param("refnodeDN"), index(param("refnodeDN"),',') + 1);
    }    

    $currentCN = substr(param("nodeDN"), 0, index(param("nodeDN"), ','));
    $actualDN = $currentCN.','.$containingDN;
    
#     print CGILOG "Drop container : $containingDN\n";
#     print CGILOG "CN : $currentCN\n";
#     print CGILOG "Real DN : $actualDN\n";

    push(@translationList, "objectclass", "alias");
    push(@translationList, "objectclass", "extensibleObject");
    push(@translationList, "aliasedObjectName", param("nodeDN"));

    $result = $ldap->add($actualDN, attr => \@translationList);
    $updateJSTree = "&updateJSTree=add";

} elsif ( param("predicate") eq "copy") {

    my ($sourceEntry, $attrList, $containingDN, $currentCN, $translationListRef);

    if ( param("nodePosType") eq "inside" ) {
        $containingDN = param("refnodeDN");
    } else {
        $containingDN = substr(param("refnodeDN"), index(param("refnodeDN"),',') + 1);
    }    

    $currentCN = substr(param("nodeDN"), 0, index(param("nodeDN"), ','));
    $actualDN = $currentCN.','.$containingDN;
    
    my $translationListRef = &createParamListByCopy(param("nodeDN"));    

    push(@$translationListRef, "objectclass", "propertyObject");

    $result = $ldap->add($actualDN, attr => $translationListRef);
    $updateJSTree = "&updateJSTree=add";

} elsif ( param("predicate") eq "update") {

    $actualDN = param("nodeDN");
        
    my $translationList = &createListfromCGIParams();

    #$result = LDAPmodifyUsingList( $ldap, param("nodeDN"), $translationList );
    $"='.';
    #print CGILOG "Update params : @$translationList\n";
    $result = $ldap->modify(param("nodeDN"), changes => [ replace => [ @$translationList ] ]);
    $updateJSTree = "&updateJSTree=modify";
    
} elsif ( param("predicate") eq "delete") {    
    $result = $ldap->delete(param("nodeDN"));
    $updateJSTree = "&updateJSTree=delete";
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

