#!/usr/bin/perl -w
use CGI qw(:standard escapeHTML);

print "Content-type: text/html\r\n\r\n";

print "--------------------------------------------------------------------------<br/>\n";
foreach $key (keys %ENV) {
    print $key.":".$ENV{$key}."<br/>\n";
}

print "--------------------------------------------------------------------------<br/>\n";
foreach (param()) {
    print $_.":".param($_)."<br/>\n";
}

