#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

#open(CGILOG, ">> /tmp/cgi.log");

$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

$currentBase = param("id");

if ( ! defined $currentBase || $currentBase eq "" || $currentBase eq "0" ) {
    $currentBase = "dc=arcore,dc=amadeus,dc=com";
}

#print CGILOG "currentBase : ".$currentBase."\n";

$msg = $ldap->search(base => $currentBase, scope => one,filter => "(objectclass=*)" );

print "Content-type: text/xml\r\n\r\n";
print "<root>";

if ( $msg->count(  ) > 0 ) {

    foreach $entry ( $msg->all_entries(  ) ) {
        if ( $entry->get_value("objectClass") eq "propertyContainer" ) {
            print "<item id='".$entry->dn(  )."' state='closed'><content><name>".$entry->get_value("cn")."</name></content></item>";
        } else {
            print "<item id='".$entry->dn(  )."' state='leaf'><content><name icon='icons/key-icon.png'>".$entry->get_value("cn")."</name></content></item>";
        }
    }
}

print "</root>\n\n\n";


