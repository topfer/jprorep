#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

require "base.pl";

print "Content-type: text/html\r\n\r\n";

print "<html><head><link type='text/css' rel='stylesheet' href='css/main.css'/></head>";
print "<body onload='top.details.document.forms.nodeForm.elements.updateJSTree.value=\"".param("updateJSTree")."\";top.selectLDAPObjType()'><table border='1' width='100%'>";
print "<tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";

my $actualPredicate = param("predicate");

if ( $actualPredicate eq "view" || $actualPredicate eq "details") {
    &generateViewForm(param("nodeDN"));
} elsif ( $actualPredicate eq "create" ) {
    &generateCreateForm(param("nodeDN"));
} elsif ( $actualPredicate eq "edit" ) {
    &generateEditForm(param("nodeDN"));
}

print "</table>";
print "</body></html>";


