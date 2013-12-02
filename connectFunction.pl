#!/usr/bin/perl

use strict;
use warnings;

require Exporter;


sub connectToDatabase{
        my $database = shift;
        my $platform = "mysql";
        my $host = "cemsdb.cems.uvm.edu";
        my $port = "3306";
        my $user = "snowcloud_admin";
        my $pw = "Yq3:1GL8";

        my $dbh = DBI->connect("DBI:$platform:$database:$port;host=$host", $user, $pw) || die "Could not connect to database: $DBI::errstr";
        return $dbh;
}

sub databaseQuery{
    my $qry = $_[0];
    my $dbase = $_[1];
    my $sth = $dbase->prepare($qry);
    my $execute = $sth->execute();
    return $execute;
}
