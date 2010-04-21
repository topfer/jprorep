#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

require "base.pl";

print "Content-type: text/html\r\n\r\n";

print "<html><head><link type='text/css' rel='stylesheet' href='css/main.css'/></head>";
print "<body onload='top.selectLDAPObjType()'><table border='1' width='100%'>";
print "<tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";

if ( param("predicate") eq "create" ) {
    &generateCreateForm(param("nodeDN"));
} else {
    &generateEditForm(param("nodeDN"));
}

print "</table>";
print "</body></html>";


