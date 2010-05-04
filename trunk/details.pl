#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

require "base.pl";

my $ldapEntry = &getLDAPEntry(param("nodeDN"));

print "Content-type: text/html\r\n\r\n";

print "<html><head><link type='text/css' rel='stylesheet' href='css/main.css'/></head>";
#print "<body onload='top.details.document.forms.nodeForm.elements.updateJSTree.value=\"".param("updateJSTree")."\";top.selectLDAPObjType()'>";
#print "<body onload='top.details.document.forms.nodeForm.elements.updateJSTree.value=\"".param("updateJSTree")."\";top.selectLDAPEntryForm(\"".$ldapEntry->get_value("objectClass")."\")'>";
print "<body onload='top.selectLDAPEntryForm(\"".$ldapEntry->get_value("objectClass")."\");top.updateJSTree(\"".param("updateJSTree")."\")'>";
#print "<table border='1' width='100%'><tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";

my $actualPredicate = param("predicate");

if ( $actualPredicate eq "view" || $actualPredicate eq "details") {
    &generateViewForm($ldapEntry);
} elsif ( $actualPredicate eq "create" ) {
    &generateCreateForm($ldapEntry);
} elsif ( $actualPredicate eq "edit" ) {
    &generateEditForm($ldapEntry);
}

#print "</table>";
print "</body></html>";


