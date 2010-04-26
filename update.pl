#!/usr/bin/perl -w
use Net::LDAP;
use URI::Escape;
use CGI qw(:standard escapeHTML);

require "base.pl";

my $actualDN, $updateJSTree;

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

    $translationList = &createListfromCGIParams();
    push(@$translationList, "objectclass", param("objectClass"));

    $updateJSTree = "&updateJSTree=add";
    $result = $ldap->add($actualDN, attr => $translationList);

} elsif ( param("predicate") eq "update") {

    $actualDN = param("nodeDN");
        
    $translationList = &createListfromCGIParams();

    $updateJSTree = "&updateJSTree=modify";
    $result = LDAPmodifyUsingList( $ldap, param("nodeDN"), $translationList );
    
} elsif ( param("predicate") eq "delete") {
    $updateJSTree = "&updateJSTree=delete";
    $result = $ldap->delete(param("nodeDN"));
}

die $result->error(  ) if $result->code(  );

$ldap->unbind;

#print CGILOG "Status: 302 Moved\nLocation:"."details.pl?nodeDN=".uri_escape($actualDN."&tab=details&predicate=view")."\n\n";
print "Status: 302 Moved\nLocation:"."details.pl?nodeDN=".uri_escape($actualDN)."&tab=details&predicate=view".$updateJSTree."\n\n";

