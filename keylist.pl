#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

require "base.pl";

open(CGILOG, ">> /tmp/cgi.log");

#my $ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

my $currentBase = param("nodeDN");
my $rootDN = "dc=arcore,dc=amadeus,dc=com";
my $depth = 0;

if ( ! defined $currentBase || $currentBase eq "" || $currentBase eq "0" ) {
    $currentBase = $rootDN;
}

$currentBase = substr($currentBase,0,rindex($currentBase, $rootDN) - 1);
my $counter = 10;
my $nextNodeStart = 0;

my $keySearchFilter;

sub getContainerLevelKeys {
    my ($currentRoot, $commentprefix, $commentpostfix) = @_;

    my $keyList = $ldap->search(base => $currentRoot, scope => one, filter => $keySearchFilter, attrs => '*');
    if ( param("includeContainerComment") == 1 ) {
        my $containerObj = getLDAPEntry($currentRoot);
        print "\n".$commentprefix.$containerObj->get_value("description").$commentpostfix."\n";        
    }
    return $keyList;
}

sub generateInheritedKeys {

    my ($prefix, $delimiter, $postfix, $commentprefix, $commentpostfix) = @_;

    my ($keyName, $keyValue, $actCN, @cnValueArr, $levelCounter, $tempoStr, $keyPrefixStr);
    
    #print "Current base : $currentBase<br/>";

    @cnValueArr = split ',',$currentBase;
    #level counter is not used currently but it could be used to limit the inheritance
    $levelCounter = 0;
    $tempoStr = "";
    $keyPrefixStr = "";

    do {        
        $actCN = pop @cnValueArr;
        $tempoStr = $actCN.",".$tempoStr;
        #print $levelCounter." : ".$tempoStr."<br/>";
        
        if ( param("prefixKeys") == 1 ) {
            $keyPrefixStr = $keyPrefixStr.substr($actCN, index($actCN, '=') + 1 ).".";
        }
        
        #set string that separates the elements of an array when expanded in a double quoted string
        $"=",";
        my $myLevelKeys = &getContainerLevelKeys($tempoStr.$rootDN, $commentprefix, $commentpostfix);

        foreach $entry ($myLevelKeys->entries) {
            if ( $entry->get_value("objectclass") eq "alias" ) {
                $entry = getLDAPEntry($entry->get_value("aliasedObjectName"));
            }
            
            if ( param("includePropertyComment") == 1 ) {
                print "\n".$commentprefix.$entry->get_value("description").$commentpostfix."\n";
            }

            $keyName = $keyPrefixStr.$entry->get_value("cn");
            print $prefix.$keyName.$delimiter.$entry->get_value("keyValue").$postfix;
        }

        $nextNodeStart = index($currentBase, ',', $nextNodeStart + 1) + 1;
        
        $levelCounter++;
    } until  ( scalar(@cnValueArr) == 0 );
}

if ( param("dereferenceLinks") eq "1" ) {
    $keySearchFilter = "(|(objectclass=propertyObject)(objectclass=alias))";
} else {
    $keySearchFilter = "(objectclass=propertyObject)";
}

if ( param("predicate") eq "export" ) {
    if ( param("exportType") eq "prop" ) {
        my $myCurrTime = &printCurrTime("_");
        #print "Content-Type:application/x-download\r\n\r\n";
        print "Content-Disposition:attachment;filename=settings_".$myCurrTime.".properties\r\n\r\n";  
        &generateInheritedKeys("","=","\n","#","");
    } elsif ( param("exportType") eq "html" ) { 
        #print CGILOG "exportType : html\n";
        print "Content-type: text/html\r\n\r\n";
        print "<html><body>\n";
        print "<table border='1' width='100%'>";
        print "<tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";

        #print "CurrentBase : ".$currentBase."<br/>";
        &generateInheritedKeys("<tr><td>","</td><td>","</td></tr>","<!--","-->");

        print "</table></body></html>\n";
    }
}

