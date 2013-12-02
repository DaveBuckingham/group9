#!/usr/bin/perl

use strict;
use DBI;
use DBD::mysql;

require 'connectFunction.pl';
require 'parseMoteData.pl';

my $dbh = connectToDatabase('snowcloud');

open(MOTEDATA, "sample_out.dat");
while (my $input = <MOTEDATA>) {
	chomp($input);
	my @motedata = &parseMoteData($input);
	my $arrSize = @motedata;
	if ($arrSize == 3) {
		#print("mote: $motedata[0], epoch: $motedata[1], timestamp: $motedata[2] \n");
		my $query = "INSERT INTO group9_epoch SET fldMote = $motedata[0], fldEpoch = $motedata[1], fldTimestamp = $motedata[2];";
		my $success = databaseQuery($query, $dbh);
		if ($success){
		    print("Success.\n");
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
