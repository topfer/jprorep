#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

require "base.pl";

# $currentBase = param("nodeDN");

# if ( ! defined $currentBase || $currentBase eq "" || $currentBase eq "0" ) {
#     $currentBase = "dc=arcore,dc=amadeus,dc=com";
# }

print "Content-type: text/html\r\n\r\n";

print "<html><head><link type='text/css' rel='stylesheet' href='css/main.css'/></head>";
print "<body onload='top.selectLDAPObjType()'><table border='1' width='100%'>";
print "<tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";

&generateViewForm(param("nodeDN"));

