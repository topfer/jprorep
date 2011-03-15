#!/usr/bin/perl -w

use DBI;
use Switch;
use URI::Escape;
use CGI qw(:standard escapeHTML);

sub listSearches() {

    # Connect to the database.
    my $dbh = DBI->connect("DBI:mysql:database=tst;host=192.168.56.101;port=3306",
                         "arcore", "",
                         {'RaiseError' => 1});

    # Now retrieve data from the table.
    my $sth = $dbh->prepare("SELECT * FROM searches");
    $sth->execute();
    while (my $ref = $sth->fetchrow_hashref()) {
        #print CGILOG logtime()."Found a row: id = ".$ref->{"sid"}."name = ".$ref->{"name"}."\n";
        print "<tr><td>".$ref->{"sid"}."</td><td>".$ref->{"name"}."</td></tr>\n";
    }
    $sth->finish();

    # Disconnect from the database.
    $dbh->disconnect();
}

################################################################################
# main function
################################################################################

switch ( param("predicate") ) {

    case "save" {
        # Connect to the database.
        my $dbh = DBI->connect("DBI:mysql:database=tst;host=192.168.56.101;port=3306",
                               "arcore", "",
                               {'RaiseError' => 1});
        my $sth = $dbh->prepare("INSERT INTO searches SET NAME = '".param("exportType")."'");
        $sth->execute();

        $sth->finish();

        # Disconnect from the database.
        $dbh->disconnect();

        print "Content-type: text/html\r\n\r\n";
        print "<html><body>\n";
        print "<table border='1' width='100%'>";
        print "<tr><th width='150px' align='right'><b>Name</b></th><th><b>Value</b></th></tr>";
        listSearches();
        print "</table></body></html>\n";
    }
}
