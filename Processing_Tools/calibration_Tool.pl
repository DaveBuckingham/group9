#!/usr/bin/perl
use strict;

use Tie::File;

use DBI;
use DBD::mysql;

require 'conversionFunctions.pl';

my $dbh= connectToDatabase('snowcloud');

if ($#ARGV != 5) {
	print "usage: calibration_tool mote modality slope intercept location comment: calibration_tool 0 'voltage' 0.342323 0.22332 'HBEF' 'Comment string'\n";
	exit;
}

my $convFile = "conversionFunctions.pl";
my $convString = "";

my @lines;
tie @lines, 'Tie::File', $convFile or die $!;

 #get info from command line @ARGV
 my $mote=$ARGV[0];
 my $modality=$ARGV[1];
 my $slope=$ARGV[2];
 my $intercept = $ARGV[3];
 my $location = $ARGV[4];
 my $comment = $ARGV[5];

my $query = sprintf("INSERT IGNORE INTO Calibration (location, mote, modality, comment) VALUES ($location, $mote, $modality, '$comment')");
print $query . "\n";
my $sth = $dbh->prepare($query);
my $execute = $sth->execute();

#get id of last insert
my $calid = $dbh->{ q{mysql_insertid}};
$convString .= sprintf("\n\$coefficients{%d}{'a'}=%f; \# %s\n", $calid, $slope, $comment);
print $convString . "\n";
$convString .= sprintf("\$coefficients{%d}{'b'}=%f; \# %s\n", $calid, $intercept, $comment);
print $convString ."\n";

for (@lines) {
    if (/# Coefficients/) {
        $_ .= $convString;
        last;
    }
}
untie @lines;
