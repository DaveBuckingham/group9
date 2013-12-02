#!/usr/bin/perl

use strict;

#parseMoteData takes line as input and returns an array of values
sub parseMoteData {
	my ($mote, $channel, $data, $record, $timestamp, $epoch, $line);
	$line = $_[0];
	if ($line =~ /^m(\d+)c(\d+)d(\d+)r(\d+)e(\d+)/) {
		($mote, $channel, $data, $record, $epoch) = ($1, $2, $3, $4, $5);
    }
    elsif ($line =~ /^m(\d+)e(\d+)t(\d+)/) {
		($mote, $epoch, $timestamp) = ($1, $2, $3);
    }
    else {
        print("invalid input: $line\n"); 
	}
	#print("$mote $channel $data $record $epoch $timestamp");
}
1;

#commented below is an example of how to maybe use the function, since assuming the input string was valid the array will be
#either 3 or 5 values long

#open(MOTEDATA, "motedata.dat");
#while ($input = <MOTEDATA>) {
#	chomp($input);
#	@motedata = &parseMoteData($input);
#	my $arrSize = @motedata;
#	if ($arrSize == 3) {
#		print("mote: $motedata[0], epoch: $motedata[1], timestamp: $motedata[2] \n");
#	} elsif ($arrSize == 5) {
#		print("mote: $motedata[0], channel: $motedata[1], data: $motedata[2], record: $motedata[3], epoch: $motedata[4] \n");
#	} else {
#		print("invalid input\n");
#	}
#}
#close(MOTEDATA);
