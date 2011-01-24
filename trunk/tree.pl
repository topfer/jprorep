#!/usr/bin/perl -w
use Net::LDAP;
use CGI qw(:standard escapeHTML);

require "base.pl";

open(CGILOG, ">> /tmp/cgi.log");

#$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

$currentBase = param("id");

if ( ! defined $currentBase || $currentBase eq "" || $currentBase eq "0" ) {
    $currentBase = "dc=arcore,dc=amadeus,dc=com";
}

#print CGILOG "currentBase : ".$currentBase."\n";

$msg = $ldap->search(base => $currentBase, scope => one,filter => "(objectclass=*)" );

print "Content-type: text/xml\r\n\r\n";
print "<root>";

if ( $msg->count(  ) > 0 ) {

    foreach $entry ( $msg->all_entries(  ) ) {
        my $entryState;
        if ( $entry->get_value("objectClass") eq "propertyContainer" ) {
            $entryState = "leaf";
            my $childrenCount = $entry->get_value( "childrenCount" );
            #print CGILOG $entry->dn(  )." : ".$childrenCount."\n";
            if ( $entry->get_value("childrenCount") && $entry->get_value("childrenCount") > 0) {
                $entryState = "closed";
            }
            print "<item id='".$entry->dn(  )."' class='container' state='".$entryState."'><content><name>".$entry->get_value("cn")."</name></content></item>";
            #print "<item id='".$entry->dn(  )."' class='container' state='closed'><content><name>".$entry->get_value("cn")."</name></content></item>";
        } elsif ( $entry->get_value("objectClass") eq "alias" || $entry->get_value("objectClass") eq "inheritingAlias") {
            my $aliasedLDAPEntry = &getLDAPEntry($entry->get_value("aliasedObjectName"));
            if ( $aliasedLDAPEntry->get_value("objectClass") eq "propertyContainer" ) {
                print "<item id='".$entry->dn(  )."' class='link' state='leaf'><content><name icon='icons/folder_link.png'>".$entry->get_value("cn")."</name></content></item>";
            } else {
                print "<item id='".$entry->dn(  )."' class='link' state='leaf'><content><name icon='icons/link.png'>".$entry->get_value("cn")."</name></content></item>";
            }
        } else {
            print "<item id='".$entry->dn(  )."' class='object' state='leaf'><content><name icon='icons/key-icon.png'>".$entry->get_value("cn")."</name></content></item>";
        }
    }
}

print "</root>\n\n\n";


