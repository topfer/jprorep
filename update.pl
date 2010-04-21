#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

require "base.pl";

#open(CGILOG, ">> /tmp/cgi.log");

sub createHashfromCGIParams {
     my $attributesArray = $_[0];

     my %replaceHash; 

     foreach $attr (@$attributesArray) {
         if ( length param($attr) > 0) {
             $replaceHash{$attr} = param($attr);
         }
     }

     return \%replaceHash;
}

sub LDAPmodifyUsingHash {
   my ($ldap, $dn, $whatToChange ) = @_;
   my $result = $ldap->modify ( $dn,
                                replace => { %$whatToChange }
                              );
   return $result;
 }

$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

$result = $ldap->bind("cn=Manager,dc=arcore,dc=amadeus,dc=com", password => "secret");
die $result->error(  ) if $result->code(  );

$oneString = "cn=".param("cn").",".param("nodeDN");

if ( param("predicate") eq "create") {

    $result = $ldap->add($oneString,
                     attr    => [ 
                                  'description' => param("description"),
                                  'objectclass' => param("objectClass") 
                   ] );
} elsif ( param("predicate") eq "update") {
    
    if ( param("objectClass") eq "propertyObject") {
        $translationHash = &createHashfromCGIParams($propertyAttrs);
    } elsif ( param("objectClass") eq "propertyContainer") {
        $translationHash = &createHashfromCGIParams($containerAttrs);
    }
    
    $result = LDAPmodifyUsingHash( $ldap, param("nodeDN"), $translationHash );
} elsif ( param("predicate") eq "delete") {
    $result = $ldap->delete(param("nodeDN"));
}

die $result->error(  ) if $result->code(  );

$ldap->unbind;

print "Status: 302 Moved\nLocation:"."view.pl?nodeDN=".$oneString."\n\n";

