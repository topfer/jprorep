#!/usr/bin/perl -w
use strict;
use Net::LDAP;
use CGI qw(:standard escapeHTML);

require "base.pl";

#open(CGILOG, ">> /tmp/cgi.log");

my $ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

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

sub printArrOfArr {

    my ($prefix, $arrOfArrRef, $oneArray) = @_;

    foreach $oneArray (@$arrOfArrRef) {
        print "$prefix :\t@$oneArray<br/>\n"
    }    
}

sub printInhTable {

    my ($tableRef, $tableKey, $outerArrRef, $innerArrRef) = @_;

    foreach $tableKey (keys %$tableRef) {
        foreach $outerArrRef (@$tableRef{$tableKey}) {
            printArrOfArr($tableKey, $outerArrRef);
        }
    }
}

################################################################################
# all the following functions operate on a data structure that can be described
# as a hash of arrays of arrays. See folowing example :
#
# my $dct = {
#    key1 => [ ["container1", "container1_key1_val", "container1_key1_descr"], 
#              ["container2", "container2_key1_val", "container2_key1_descr"], 
#              ["container3", "container3_key1_val", "container3_key1_descr"] ],
#    key2 => [ ["container1", "container1_key2_val", "container1_key2_descr"], 
#              ["container2", "container2_key2_val", "container2_key2_descr"] ],
#    key3 => [ ["container1", "container1_key3_val", "container1_key3_descr"], 
#              ["container2", "container2_key3_val", "container2_key3_descr"],
#              ["container3", "container3_key3_val", "container3_key3_descr"], 
#              ["container4", "container4_key3_val", "container4_key3_descr"] ]
# };
#
# understanding of the above structure the way it can be manipulated is vital
# for comprehending the following functions that operate on it
# in most functions we refer to this structure as the "inheritance table"
################################################################################


sub printInhTableToHTML {

    my ($inheritanceTable, $tableKey, $outerArrRef, $oneArray, $myListIter) = @_;

    foreach $tableKey (keys %$inheritanceTable) {

        foreach $outerArrRef (@$inheritanceTable{$tableKey}) {

            #print CGILOG logtime()." $tableKey=".@$outerArrRef."\n";

            print "\n<tr><td>\n";                
            
            if ( param("showSettingsOverwrite") == 1) {
                $myListIter = 0;
                while ($myListIter < scalar(@$outerArrRef) - 1) {
                    print "<strike>".$outerArrRef->[$myListIter]->[0]."</strike><br/>";
                    $myListIter++;
                }
            }

            print $outerArrRef->[scalar(@$outerArrRef) - 1]->[0];
            
            print "</td><td>\n";

            if ( param("showSettingsOverwrite") == 1) {
                $myListIter = 0;
                while ($myListIter < scalar(@$outerArrRef) - 1) {
                    print "<strike>".$outerArrRef->[$myListIter]->[1]."</strike><br/>";
                    $myListIter++;
                }
            }

            print $outerArrRef->[scalar(@$outerArrRef) - 1]->[1];

            print "</td></tr>";
        }        
    }
}

sub printInhTableToJPROP {

    my ($inheritanceTable, $tableKey, $outerArrRef, $oneArray, $myListIter) = @_;

    foreach $tableKey (keys %$inheritanceTable) {

        foreach $outerArrRef (@$inheritanceTable{$tableKey}) {

            #print CGILOG logtime()." $tableKey=".@$outerArrRef."\n";

            if ( param("showSettingsOverwrite") == 1) {
                $myListIter = 0;
                while ($myListIter < scalar(@$outerArrRef) - 1) {
                    print "#".$outerArrRef->[$myListIter]->[0]."=".$outerArrRef->[$myListIter]->[1]."\n";
                    $myListIter++;
                }
            }
                        
#             if ( param("showSettingsOverwrite") == 1) {
#                 $myListIter = scalar(@$outerArrRef) - 1;
#                 while ($myListIter > 0) {
#                     print "#".$outerArrRef->[$myListIter]->[0]."=".$outerArrRef->[$myListIter]->[1]."\n";
#                     $myListIter--;
#                 };
#             }

            print $outerArrRef->[scalar(@$outerArrRef) - 1]->[0]."=".$outerArrRef->[scalar(@$outerArrRef) - 1]->[1]."\n";
#            print $outerArrRef->[0]->[0]."=".$outerArrRef->[0]->[1]."\n";
        }        
    }
}




################################################################################
################################################################################
sub appendArray {

    my ($tableRef, $thisKey, $arrayRef, $tempRef) = @_;

    #print CGILOG logtime()." appendArray(\"tableRef\",\"".$thisKey."\",\"[@$arrayRef]\")\n";

    if ( exists($$tableRef{$thisKey}) ) {
        $tempRef = @$tableRef{$thisKey};
        push(@$tempRef,$arrayRef);
    } else {
        $$tableRef{$thisKey} = [ $arrayRef ];
    }
}

################################################################################
# Generates an object of class LDAP::Search that contains all keys of
# the current container
# arg1 - The DN that is the base object entry relative to which the search 
#        is to be performed.
# arg2 - tag that preceeds the comment that is to be added for the container 
#        ("<!--" or "#" or "")
# arg3 - tag to suceeds the comment that is to be added for the container 
#        ("-->" or "")
################################################################################
sub getContainerLevelKeys {
    my ($currentRoot, $commentprefix, $commentpostfix) = @_;

    #print CGILOG logtime()."getContainerLevelKeys(\"".$currentRoot,"\",\"".$commentprefix."\",\"".$commentpostfix."\")\n";

    my $keyList = $ldap->search(base => $currentRoot, scope => "one", filter => $keySearchFilter, attrs => '*');
    if ( param("includeContainerComment") == 1 ) {
        my $containerObj = getLDAPEntry($currentRoot);
        #this following statement is supposed to print the container level description
        #print "\n".$commentprefix.$containerObj->get_value("description").$commentpostfix."\n";        
    }
    return $keyList;
}

################################################################################
################################################################################
sub addContainerKeysToInheritanceTable {
    my ($containerDN, $inheritanceTable) =@_;
    
    my ($myLevelKeys, $containerPrefix, $entry, $entryCN);

    $myLevelKeys = getContainerLevelKeys($containerDN, "", "");

    $containerPrefix = $containerDN;

    #replace all string of ",cn=" or "cn=" with dots(".")
    $containerPrefix =~ s/,*[[:alpha:]]+=/./g;

    foreach $entry ($myLevelKeys->entries) {
        $entryCN = $entry->get_value("cn");
        
        if ( $entry->get_value("objectclass") eq "inheritingAlias" || 
            $entry->get_value("objectclass") eq "alias") {
            $entry = getLDAPEntry($entry->get_value("aliasedObjectName"));
        }

        #add key only if it's an object or an alias to an object
        if ( $entry->get_value("objectclass") eq "propertyObject" ) {
            appendArray($inheritanceTable, $entryCN, [join(".", reverse split(/\./, $containerPrefix)).$entryCN, $entry->get_value("keyValue"), $entry->get_value("description")]);
        }
    }
}

################################################################################
# arg1 - The DN that is the base object entry relative to which the search 
#        is to be performed.
# arg2 - current depth of search (during the recursive calls this depth will
#        decrease to 0
# arg3 - inheritance table in which the keys of the current container will be
#        inserted
################################################################################
sub gatherChildKeys {
    
    my ($currentDN, $depth, $inheritanceTable) = @_;

    #print CGILOG logtime()."gatherChildKeys(\"".$currentDN,"\",\"".$depth."\")\n";

    my $keyList = $ldap->search(base => $currentDN, scope => "one", filter => "(|(objectclass=propertyContainer)(objectclass=alias)(objectclass=inheritingAlias))", attrs => "*");

    my $entry;
    my $followPath;

    if ($depth >= 0) {

        addContainerKeysToInheritanceTable($currentDN, $inheritanceTable);

        foreach $entry ($keyList->entries) {

            #normally we do follow links, unless the link points to a non container
            $followPath = 1;

            #in case we stumbled upon a link get the linked object
            if ( $entry->get_value("objectclass") eq "inheritingAlias" || 
                 $entry->get_value("objectclass") eq "alias" ) {
                $entry = getLDAPEntry($entry->get_value("aliasedObjectName"));
            }

            #if the link doesn't point to a container no follow-up needed
            if ( $entry->get_value("objectclass") ne "propertyContainer" ) {
                $followPath = 0;
            }
            
            #in case we are still on with the path follow-up let's just do exactly that
            if ($followPath == 1) {
                gatherChildKeys($entry->dn(), $depth - 1, $inheritanceTable);
            }
        }
    }
}

################################################################################
# Recursive function that travels up the inheritance tree and adds the object
# keys of each level to the inheritance table. The recursive call occurs before
# the actual addition of the keys of the current level, so the inheritance table
# is built up on the way returning from the recursion. 
# The recursion stops when the top of the three is reached, that is, the DN of
# the current container is equal with the DN of the root, or when the requested
# height is reached.
# arg1 - The DN that is the base object entry relative to which the search 
#        is to be performed.
# arg2 - current height of search. During the recursive calls this height will
#        decrease towards 0 (it might not get to 0 if the top of the tree is
#        reached sooner)
# arg3 - inheritance table in which the keys of the current container will be
#        inserted
################################################################################
sub gatherParentKeys {
    my ($currDNValue, $listType, $height, $inheritanceTable) = @_;

    #print CGILOG logtime()."gatherParentKeys(\"".$currDNValue."\",\"".$listType."\",\"".$height."\",\"".$inheritanceTable.")\n";

    if ( $height > 0 && $currDNValue ne $rootDN ) {
        $inheritanceTable = gatherParentKeys(substr($currDNValue, index($currDNValue,",") + 1), "html", $height-1, {});
    }

    addContainerKeysToInheritanceTable($currDNValue, $inheritanceTable);

    return $inheritanceTable;    
}

################################################################################
# Function that achieves the same result as above but in a non-recursive maner
# As this functions deals with each level sequentially as it travels up the
# tree, the resulting inheritance table is reversed. The current way of
# displaying the inheritance table should be adapted if this function is to be
# used.
# arg1 - The DN that is the base object entry relative to which the search 
#        is to be performed.
# arg2 - current height of search
# arg3 - inheritance table in which the keys of the current container will be
#        inserted
################################################################################
sub disabled_gatherParentKeys {
    my ($currDNValue, $listType, $upInherit, $inheritanceTable) = @_;

    my ($tempCNDelimiterIndex, $containerPrefix);

    $inheritanceTable = {};

    do {

        addContainerKeysToInheritanceTable($currDNValue, $inheritanceTable);

        $tempCNDelimiterIndex = index($currDNValue,",");
        $currDNValue = substr($currDNValue, $tempCNDelimiterIndex + 1);
        $upInherit--;

    } until ( $tempCNDelimiterIndex == -1 || $upInherit == 0 );

    return $inheritanceTable;    
}

################################################################################
# generate complete inheritance table by calling the functions for
# upwards and downwards inharitance as needed 
################################################################################
sub genInheritanceTable {
    my ($listType) = @_;

    my $inheritanceTable;

    #gather parent keys if required or just initialise the inheritance table
    if ( param("upwardInheritance") > 0 ) {
        $inheritanceTable = gatherParentKeys(substr($currentBase.",".$rootDN, index($currentBase.",".$rootDN,",") + 1), $listType, param("upwardInheritance") - 1, {});
    } else {
        $inheritanceTable = {};
    }

    #gather child keys (that includes the current container) if required or just add the current container
    if ( param("downwardInheritance") > 0 ) {
        gatherChildKeys($currentBase.",".$rootDN, param("downwardInheritance"), $inheritanceTable);
    } else {
        addContainerKeysToInheritanceTable($currentBase.",".$rootDN, $inheritanceTable);
    }

    return $inheritanceTable;

}

################################################################################
# main function
################################################################################
if ( param("dereferenceLinks") eq "1" ) {
    $keySearchFilter = "(|(objectclass=propertyObject)(objectclass=alias)(objectclass=inheritingAlias))";
} else {
    $keySearchFilter = "(objectclass=propertyObject)";
}

if ( param("predicate") eq "export" ) {
    if ( param("exportType") eq "prop" ) {
        my $myCurrTime = &printCurrTime("_");
        #print "Content-Type:application/x-download\r\n\r\n";
        print "Content-Disposition:attachment;filename=settings_".$myCurrTime.".properties\r\n\r\n";  

        #my $inheritanceTable = gatherParentKeys($currentBase.",".$rootDN, "prop", param("upwardInheritance"), {});
        my $inheritanceTable = genInheritanceTable("prop");

        printInhTableToJPROP($inheritanceTable);
    } elsif ( param("exportType") eq "html" ) { 
        #print CGILOG "exportType : html\n";
        print "Content-type: text/html\r\n\r\n";
        print "<html><body>\n";
        print "<table border='1' width='100%'>";
        print "<tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";

        #my $inheritanceTable = gatherParentKeys($currentBase.",".$rootDN, "html", param("upwardInheritance"), {});
        my $inheritanceTable = genInheritanceTable("html");
        
        printInhTableToHTML($inheritanceTable);

        print "</table></body></html>\n";
    }
}

