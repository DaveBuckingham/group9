#!/usr/bin/perl

#Snowcloud Project 
#Coded By: Jonathan Russo

#This script will fix all of the timestamps in the backloged epoch entries

use strict;
use DBI;
use DBD::mysql;

#get functions
require 'functions.pl';

#connect to database
my $dbh= connectToDatabase('snowcloud');

for(my $n=2; $n<7; $n++){
	print "Starting node:$n\n";	
	#for each node...
	my $query = "SELECT TIME, epoch FROM epoch WHERE node =$n AND TIME <  '2012-01-11' AND TIME !=  '0000-00-00 00:00:00' ORDER BY epoch";
	print $query . "\n";
	my $sth = $dbh->prepare($query);
	$sth->execute(); 
		
	my $lastTime;
	my $epoch;
	$sth->bind_columns(undef, \$lastTime, \$epoch);
			
	$sth->fetch();
	print "Time:$lastTime, Epoch:$epoch\n";
	for(my $e=$epoch-1; $e>-1; $e--){
		print "Starting earlier epoch conversion:\n";
		my $query = "Select epochID from epoch where node =$n and epoch = $e AND TIME <  '2012-01-11'";
		print $query . "\n";
		my $sth = $dbh->prepare($query);
		$sth->execute(); 
		
		my $id;
		$sth->bind_columns(undef, \$id);

		$sth->fetch();
		print "EpochID:$id\n";
		
		my $query = "UPDATE epoch SET time = SUBTIME('$lastTime', '1:0:0'), isInferred=1 where epochID=$id";
		print $query . "\n";
		my $sth = $dbh->prepare($query);
		$sth->execute(); 

		my $query = "Select time from epoch where epochID=$id";
		print $query . "\n";
		my $sth = $dbh->prepare($query);
		$sth->execute(); 
		
		my $temp;
		$sth->bind_columns(undef, \$temp);
					
		$sth->fetch();
		print "LastTime:$temp\n";
		$lastTime=$temp;	
	}

	$epoch++;	
	for(; $epoch<1991; $epoch++){
		print "Starting later epoch conversion:\n";		
		#for each epoch
		my $query = "Select time, epochID from epoch where node =$n and epoch = $epoch AND TIME <  '2012-01-11'";
		print $query . "\n";
		my $sth = $dbh->prepare($query);
		$sth->execute(); 
		
		my $dTime;
		my $id;
		$sth->bind_columns(undef, \$dTime, \$id);
					
		$sth->fetch();
		print "Time:$dTime, EpochID:$id\n";		

		if($dTime eq "0000-00-00 00:00:00"){
			my $query = "UPDATE epoch SET time = ADDTIME('$lastTime', '1:0:0'), isInferred=1 where epochID=$id";
			print $query . "\n";
			my $sth = $dbh->prepare($query);
			$sth->execute(); 
			
			my $query = "Select time from epoch where epochID=$id";
			print $query . "\n";
			my $sth = $dbh->prepare($query);
			$sth->execute(); 
		
			my $temp;
			$sth->bind_columns(undef, \$temp);
					
			$sth->fetch();
			print "LastTime:$temp\n";
			$lastTime=$temp;
		}else{
			$lastTime=$dTime;
			print "No Change\n";
		}
	}
	$lastTime=0;
	$epoch=0;
}
