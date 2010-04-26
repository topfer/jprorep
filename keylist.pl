#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

#require "base.pl";

#open(CGILOG, ">> /tmp/cgi.log");

sub getContainerLevelKeys {
    my $keyList = $ldap->search(base => $_[0], scope => one, filter => "(|(objectclass=propertyObject)(objectclass=alias))", attrs => '*');
    return $keyList;
}

$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

$currentBase = param("nodeDN");
$rootDN = "dc=arcore,dc=amadeus,dc=com";

if ( ! defined $currentBase || $currentBase eq "" || $currentBase eq "0" ) {
    $currentBase = $rootDN;
}

$msg = $ldap->search(base => $currentBase, scope => one, filter => "(|(objectclass=propertyObject)(objectclass=alias))", attrs => '*');

print "Content-type: text/html\r\n\r\n";

print "<html><body onload='top.operationFrameLoaded()'>\n";
print "<table border='1' width='100%'>";
print "<tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";

$currentBase = substr($currentBase,0,rindex($currentBase, $rootDN) - 1);
my $counter = 10;
my $nextNodeStart = 0;

do {
    my $myLevelKeys = &getContainerLevelKeys(substr($currentBase, $nextNodeStart).",".$rootDN);

    foreach $entry ($myLevelKeys->entries) {
        print "<tr><td>".$entry->get_value("cn")."</td><td>".$entry->get_value("keyValue")."</td></tr>";
    }

    $nextNodeStart = index($currentBase, ',', $nextNodeStart + 1) + 1;
    $counter--;
} until  ( $nextNodeStart == 0  || $counter < 0);

print "</table></body></html>\n";

