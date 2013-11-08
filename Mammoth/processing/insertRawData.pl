#!/usr/bin/perl

#Snowcloud Project 
#Coded By: Jonathan Russo

#This script will pull data from files in the $dir directory and insert the raw data into the database.

use lib '/home/cs/csugrads/jrusso/local/lib/perl5/site_perl/5.8.8/';
#include statement needed for File::stat module

use strict;
use File::stat;
use Date::Parse;
use DBI;
use DBD::mysql;

#get functions
require 'functions.pl';

#connect to database
my $dbh= connectToDatabase('snowcloud');

my $dir = "testbed/";

opendir FILEDIR, $dir or die $!;
my @files = readdir(FILEDIR);
closedir(FILEDIR);

my %goodDataInfo;
my %badDataInfo;
my $badCounter=0;


foreach my $fn (@files){
	
	next if ($fn =~ m/^\./);
	
	my $fullfile = $dir . $fn;			
	my $epochTimeStamp = stat($fullfile)->mtime;
	
	#read file for actual data
	open FILE, "<", $dir . $fn or die $!;
	my @lines = <FILE>;
	my $lineCounter=1;		
		
	foreach my $line (@lines){
		if($line =~ /^5\s5\s5\s5\s(\d{4}-\d{2}-\d{2})\s(\d{2}:\d{2}:\d{2})$/){
			$badCounter++;							
		}elsif($line =~ /^(\d{1,2})\s(\d{1})\s(\d{1})\s(\d+)\s(\d{4}-\d{2}-\d{2})\s(\d{2}:\d{2}:\d{2})$/){
			
			my $readingNum = $1;			
			my $currentNode=$2;
			my $channel = $3;
			my $data = $4;

			if($channel ==7){
				$goodDataInfo{$currentNode}{$data}{'epochTimeStamp'}= $epochTimeStamp;

				if($goodDataInfo{$currentNode}{-1}){				
					#insert into database if there is data for that epoch and no bad data before it.

					if(!$badCounter){
						my $query ="INSERT IGNORE INTO epoch (node, epoch, time) VALUES ($currentNode, $data, 
FROM_UNIXTIME($goodDataInfo{$currentNode}{$data}{'epochTimeStamp'}))";
						my $sth = $dbh->prepare($query);
						$sth->execute();

						my $epochID = getEpochId($currentNode, $data, $dbh);
					 
						for (my $c = 0; $c < 7; $c++) {				 			
							$goodDataInfo{$currentNode}{$data}{$c}= \%{$goodDataInfo{$currentNode}{-1}{$c}};
					
							foreach(keys %{$goodDataInfo{$currentNode}{$data}{$c}}){
						
								#insert into database
								$query ="INSERT INTO rawData (epochID, sensor, data, time, lineNumber) VALUES ($epochID, $c, 
$goodDataInfo{$currentNode}{$data}{$c}{$_}{'data'}, FROM_UNIXTIME($goodDataInfo{$currentNode}{$data}{$c}{$_}{'time'}), $_)";	
								my $sth = $dbh->prepare($query);
								$sth->execute();
							}
						}
					}
				} 

				delete $goodDataInfo{$currentNode}{-1};
			}else{										
				$goodDataInfo{$currentNode}{-1}{$channel}{$readingNum}{'data'}=$data;
				$goodDataInfo{$currentNode}{-1}{$channel}{$readingNum}{'time'}=str2time($5 . " " . $6);			
			}
		}	
	}

	if($badCounter){#insert bad info into database
		my $query ="INSERT INTO badData (count, time) VALUES ($badCounter, FROM_UNIXTIME($epochTimeStamp))";
		my $sth = $dbh->prepare($query);
		$sth->execute();
		$badCounter=0;
	}
 
	close FILE;
} 

#Delete bad data values from db
my $query ="DELETE FROM rawData WHERE data=4095";
my $sth = $dbh->prepare($query);
$sth->execute();

#delete temporary hash
foreach(keys %goodDataInfo){
	delete $goodDataInfo{$_}{-1};
}

###Output Data(Debug)
foreach my $nodeNum (sort {$a<=>$b} keys %goodDataInfo){
#	print "############################################\n";	
#	print "Node Number: " . $nodeNum . "\n";

	foreach my $epoch (sort {$a<=>$b} keys %{$goodDataInfo{$nodeNum}}){
		
#		print "Start Epoch: " . $epoch . " Unix Time: " . $goodDataInfo{$nodeNum}{$epoch}{'epochTimeStamp'} . "\n";
		foreach my $channels (sort {$a<=>$b} keys %{$goodDataInfo{$nodeNum}{$epoch}}){ 
			next if($channels =~ /epochTimeStamp/);			
#			print "Start Channel:" . $channels . "\n";
			foreach my $reading (sort {$a<=>$b} keys %{$goodDataInfo{$nodeNum}{$epoch}{$channels}}){				
#				print "Reading #: $reading Data : " . $goodDataInfo{$nodeNum}{$epoch}{$channels}{$reading}{'data'} . "  Time: " . $goodDataInfo{$nodeNum}{$epoch}{$channels}{$reading}{'time'} . "\n";
				
			}
#			print "End Channel: $channels\n";
		}
#		print "End Epoch: $epoch\n";	
	}
#	print "End Node $nodeNum \n############################################\n";	
}

