#!/usr/bin/perl

#Snowcloud Project 
#Coded By: Jonathan Russo

#This script will pull data in from select backlog files in the $dir directory and insert the raw data into the database.

use lib '/home/cs/csugrads/jrusso/local/lib/perl5/site_perl/5.8.8/';
#include statement need for File::stat on cems server

use strict;
use File::stat;
use Date::Parse;
use DBI;
use DBD::mysql;

#get functions
require 'functions.pl';

#connect to database
my $dbh= connectToDatabase('snowcloud');

my $dir = "backlogData/";

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
			
		
	foreach my $line (@lines){
		if($line =~ /^mote=(\d{1});chan=(\d{1});data=(\d+);record=(\d+);$/){
			
			my $currentNode=$1;
			my $channel = $2;
			my $data = $3;
			my $epoch = $4-10000;

			$goodDataInfo{$currentNode}{$epoch}{'epochTimeStamp'}= $epochTimeStamp;

			$goodDataInfo{$currentNode}{$epoch}{$channel}=$data;
			
			my $epochID = getEpochId($currentNode, $epoch, $dbh);
			
			if(!$epochID){							
				my $query ="INSERT IGNORE INTO epoch 
(node, epoch, time) VALUES ($currentNode, $epoch, NULL)";
				print $query . "\n";
				my $sth = $dbh->prepare($query);
				$sth->execute();
				
				$epochID = getEpochId($currentNode, $epoch, $dbh);
			}

						 							
			#insert into database
			my $query ="INSERT INTO backlogData (epochID, sensor, data) VALUES ($epochID, $channel, $data)";	
			print $query . "\n";
			my $sth = $dbh->prepare($query);
			$sth->execute();
							 
			
			$epochID=0;
		}	
	}
 
	close FILE;
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
#			print "Reading: $goodDataInfo{$nodeNum}{$epoch}{$channels} \n";
#			print "End Channel: $channels\n";
		}
#		print "End Epoch: $epoch\n";	
	}
#	print "End Node $nodeNum \n############################################\n";	
}

