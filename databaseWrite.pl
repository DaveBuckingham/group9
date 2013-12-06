#!/usr/bin/perl

use strict;
BEGIN { unshift @INC, '/users/g/j/gjohnso4/lib/perl/lib/perl5/x86_64-linux-thread-multi' };
BEGIN { unshift @INC, '/users/g/j/gjohnso4/lib/perl/lib64/perl5' };
use DBI;
use DBD::mysql;

require 'connectFunction.pl';
require 'parseMoteData.pl';

my $dbh = connectToDatabase('snowcloud');
if (!@ARGV){
    die "no input file";
}
	open(MOTEDATA, "$ARGV[0]");
	while (my $input = <MOTEDATA>) {
		chomp($input);
		my @motedata = &parseMoteData($input);
		my $arrSize = @motedata;
		if ($arrSize == 3) {
		        my $timestamp = $motedata[2];
                        my ($S, $M, $H, $d, $m, $y) = localtime($timestamp);
                        $m += 1;
                        $y += 1900;
                        my $dt = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $y,$m,$d,$H,$M,$S);
                        print ("$dt\n");
			#print("mote: $motedata[0], epoch: $motedata[1], timestamp: $motedata[2] \n");
		        my $query = "UPDATE group9_rawData SET fldTimestamp = '$dt' WHERE fldMote = $motedata[0] and fldEpoch = $motedata[1];";
			my $success = databaseQuery($query, $dbh);
			if ($success){
				print("Success.\n");
			} else {
			        print("Failed.\n");
                        }

	
		} elsif ($arrSize == 5) {
			#print("mote: $motedata[0], channel: $motedata[1], data: $motedata[2], record: $motedata[3], epoch: $motedata[4] \n");
			my $query = "INSERT INTO group9_rawData SET fldMote = $motedata[0], fldChannel = $motedata[1], fldData = $motedata[2], fldRecord = $motedata[3], fldEpoch = $motedata[4];";
			my $success = databaseQuery($query, $dbh);
			if ($success){
				print("Success.\n");
			}
	
		} else {
			print("invalid input\n");
		}
	}
	close(MOTEDATA);
