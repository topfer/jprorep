#!/usr/bin/perl -w

use DBI;
use Net::LDAP;
use Switch;
use URI::Escape;
use CGI qw(:standard escapeHTML);

require "base.pl";

open(CGILOG, ">> /tmp/cgi.log");

sub listSearches() {

    # Now retrieve data from the table.
    my $sth = $dbh->prepare("SELECT * FROM searches");
    $sth->execute();

    while (my $ref = $sth->fetchrow_hashref()) {
        #print CGILOG logtime()."Found a row: id = ".$ref->{"id"}."name = ".$ref->{"srcname"}."\n";
        print "<tr><td><a href=keylist.pl?predicate=load&srcId=".$ref->{"id"}.">".$ref->{"id"}."</a>".
              "<td><a href=keylist.pl?predicate=load&srcName=".$ref->{"srcname"}.">".$ref->{"srcname"}."</a>".
               "</td><td>".$ref->{"created"}.
               "</td></tr>\n";
    }

    $sth->finish();
}

################################################################################
# main function
################################################################################

# Connect to the database.
print CGILOG logtime()."Attempt to open DB connection\n";
$dbh = DBI->connect("DBI:mysql:database=arcoremgmt;host=192.168.56.101;port=3306",
                       "arcore_user", "",
                       {'RaiseError' => 1});
print CGILOG logtime()."DB connection open\n";

print CGILOG logtime()."Predicate : ".param("predicate")."\n";

switch ( param("predicate") ) {

    case "list" {
        print "Content-type: text/html\r\n\r\n";
        print "<html><body>\n";
        print "<table border='1' width='100%'>";
        print "<tr><th width='150px' align='right'><b>ID</b></th><th><b>Name</b></th><th><b>Created</b></th></tr>";
        listSearches();
        print "</table></body></html>\n";        
    }
    case "save" {
        
        $testStr = "INSERT INTO searches \
                                (srcname, \
                                 nodedn, \
                                 enable_settings_inheritance, \
                                 upward_inheritance, \
                                 downward_inheritance, \
                                 enable_settings_overwrite, \ 
                                 show_settings_overwrite, \ 
                                 include_container_comment, \
                                 include_property_comment, \ 
                                 dereference_links, \
                                 prefix_keys, \
                                 prefix_keys_separator) \
                                VALUES (".
                                "'".param("actionPrameter")."',".
                                "'".param("nodeDN")."',".
                                param("enableSettingsInheritance").",".
                                param("upwardInheritance").",".
                                param("downwardInheritance").",".
                                param("enableSettingsOverwrite").",".
                                param("showSettingsOverwrite").",".
                                param("includeContainerComment").",".
                                param("includePropertyComment").",".
                                param("dereferenceLinks").",".
                                param("prefixKeys").",".
                                "'".param("prefixKeysSeparator")."')";

        #print CGILOG logtime()."SQL : ".$testStr."\n";

        my $sth = $dbh->prepare($testStr);
        $sth->execute();

        $sth->finish();

        print "Content-type: text/html\r\n\r\n";
        print "<html><body>\n";
        print "<table border='1' width='100%'>";
        print "<tr><th width='150px' align='right'><b>ID</b></th><th><b>Name</b></th><th><b>Created</b></th></tr>";
        listSearches();
        print "</table></body></html>\n";
    }
}

# Disconnect from the database.
$dbh->disconnect();

