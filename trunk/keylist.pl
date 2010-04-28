#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

#require "base.pl";

#open(CGILOG, ">> /tmp/cgi.log");

my $ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

my $currentBase = param("nodeDN");
my $rootDN = "dc=arcore,dc=amadeus,dc=com";

if ( ! defined $currentBase || $currentBase eq "" || $currentBase eq "0" ) {
    $currentBase = $rootDN;
}

my $msg = $ldap->search(base => $currentBase, scope => one, filter => "(|(objectclass=propertyObject)(objectclass=alias))", attrs => '*');

$currentBase = substr($currentBase,0,rindex($currentBase, $rootDN) - 1);
my $counter = 10;
my $nextNodeStart = 0;

sub getContainerLevelKeys {
    my $keyList = $ldap->search(base => $_[0], scope => one, filter => "(|(objectclass=propertyObject)(objectclass=alias))", attrs => '*');
    return $keyList;
}

sub generateInheritedKeys {

    $prefix = $_[0];
    $delimiter = $_[1];
    $postfix = $_[2];

    do {
        my $myLevelKeys = &getContainerLevelKeys(substr($currentBase, $nextNodeStart).",".$rootDN);

        foreach $entry ($myLevelKeys->entries) {
            print $prefix.$entry->get_value("cn").$delimiter.$entry->get_value("keyValue").$postfix;
        }

        $nextNodeStart = index($currentBase, ',', $nextNodeStart + 1) + 1;
        $counter--;
    } until  ( $nextNodeStart == 0  || $counter < 0);
}

if ( param("predicate") eq "export" ) {
    print "Content-Type:application/x-download\r\n\r\n";  
    #print "Content-Disposition:attachment;filename=toto.txt\r\n\r\n";  
    &generateInheritedKeys("","=","\n");
} else { 
    print "Content-type: text/html\r\n\r\n";
    print "<html><body onload='top.operationFrameLoaded()'>\n";
    print "<table border='1' width='100%'>";
    print "<tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";

    &generateInheritedKeys("<tr><td>","</td><td>","</td></tr>");

    print "</table></body></html>\n";
}

