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

sub checkOverWrite {
    my ($key, $keyPrefixStr, $overWrArrRef, $level) = @_;
    my $localLevel = 0;
    my $localKey;
    my @tmpArr = @{$overWrArrRef};

    while ( $localLevel < $level ) {
        foreach $localKey ( keys %{ ${$overWrArrRef}[$localLevel] }) {
            if ( ($localKey eq $key) and (${$overWrArrRef}[$localLevel]{$localKey}[2] eq "") ) {
                ${$overWrArrRef}[$localLevel]{$localKey}[2] = $keyPrefixStr;
            }
        }
        $localLevel++;
    }
}

sub generateInheritedKeys {

    my ($prefix, $delimiter, $postfix, $commentprefix, $commentpostfix) = @_;

    my ($keyName, $keyValue, $containerCN, @cnValueArr, $levelCounter, $partialDN, $keyPrefixStr, @overWrArr, $actEntryCN, $actEntryDN);

    my ($strikeOutPrefix, $strikeOutDelimiter, $strikeOutpostix); 
    
    #print "Current base : $currentBase<br/>";

    #split based on inheritance setting
    if ( param("enableSettingsInheritance") == 1 ) {
        #in case inheritance is set just break up the cn and follow through from top to bottom
        @cnValueArr = split ',',$currentBase;
    } else {
        #if inheritance is not enabled just the current cn as one single member of the array
        $cnValueArr[0] = "$currentBase";
    }
    #level counter is not used currently but it could be used to limit the inheritance
    $levelCounter = 0;
    $partialDN = $rootDN;
    $keyPrefixStr = "";

    do {        
        $containerCN = pop @cnValueArr;
        $partialDN = $containerCN.",".$partialDN;
        
        if ( param("prefixKeys") == 1 ) {
            $keyPrefixStr = $keyPrefixStr.substr($containerCN, index($containerCN, '=') + 1 ).".";
        }
        
        #set string that separates the elements of an array when expanded in a double quoted string
        $"=",";
        my $myLevelKeys = &getContainerLevelKeys($partialDN, $commentprefix, $commentpostfix);

        foreach $entry ($myLevelKeys->entries) {
            $actEntryCN = $entry->get_value("cn");
            
            #print CGILOG "Key name : ".$actEntryCN."\n";
            if ( $entry->get_value("objectclass") eq "alias" ) {
                $entry = getLDAPEntry($entry->get_value("aliasedObjectName"));
            }
            
#             if ( param("includePropertyComment") == 1 ) {
#                 print "\n".$commentprefix.$entry->get_value("description").$commentpostfix."\n";
#             }

            $keyName = $keyPrefixStr.$actEntryCN;
            #print $prefix.$keyName.$delimiter.$entry->get_value("keyValue").$postfix;

            &checkOverWrite($actEntryCN, $keyPrefixStr, \@overWrArr, $levelCounter);
            $overWrArr[$levelCounter]{$actEntryCN} = [$actEntryCN, $keyPrefixStr, "", $entry->get_value("keyValue"), $entry->get_value("description")];

            #my @tstArr = $overWrArr[$levelCounter]{$actEntryCN};
        }

        $nextNodeStart = index($currentBase, ',', $nextNodeStart + 1) + 1;
        
        $levelCounter++;
    } until  ( scalar(@cnValueArr) == 0 );

    foreach $levelHash (@overWrArr) {
        foreach $levelKey ( keys %$levelHash ) {
            if ( param("includePropertyComment") == 1 ) {
                print "\n".$commentprefix.${$levelHash}{$levelKey}[4].$commentpostfix."\n";
            }
            
            if ( ${$levelHash}{$levelKey}[2] eq "" ) {
                print $prefix.${$levelHash}{$levelKey}[1].$levelKey.$delimiter.${$levelHash}{$levelKey}[3].$postfix;
            } else {
                print $prefix."<strike>".${$levelHash}{$levelKey}[1].$levelKey."</strike><br/>".${$levelHash}{$levelKey}[2].$levelKey.$delimiter."<strike>".${$levelHash}{$levelKey}[3]."</strike>".$postfix;
            }
        }
        $localLevel++;
    }

#     foreach $levelHash (@overWrArr) {
#         print CGILOG "[";
#         foreach $levelKey ( keys %$levelHash ) {
#             print CGILOG "[",$levelKey."=[".join(",",@{ ${$levelHash}{$levelKey} })."],"
#         }
#         print CGILOG "]\n";
#         $localLevel++;
#     }

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

