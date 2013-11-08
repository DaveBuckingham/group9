#!/usr/bin/perl

#Snowcloud Project
#Coded By: Jonathan Russo

#This script will insert new backlog items into the database and set proper timestamps for them.

use strict;
use DBI;
use DBD::mysql;
use ConversionFunctions;

#get functions
#require 'functions.pl';

#connect to database
my $dbh= connectToDatabase('snowcloud');

my $dir = "newBacklogData/";

opendir FILEDIR, $dir or die $!;
my @files = readdir(FILEDIR);
closedir(FILEDIR);

my %goodDataInfo;
my @newEpochs;
my $location = 'HBEF';


foreach my $fn (@files){

	next if ($fn =~ m/^\./);

	my $fullfile = $dir . $fn;
	#read file for actual data
	open FILE, "<", $dir . $fn or die $!;
	my @lines = <FILE>;
	my $lastTime=0;
	my $lastEpoch=-1;
	my $epochID=0;
	my $node023Start="2012-12-12 15:00:00";
	my $node456Start="2012-12-12 15:00:00";
	my %nodeStarts;

	foreach my $line (@lines){
		if($line =~ /^(\d{1})\s+(\d{1})\s+(\d+)\s+(\d+)$/){

			#get info from line
			my $currentNode=$1;
			my $channel = $2;
			my $data = $3;
			my $epoch = $4;

			if($epoch < 0){
				next;
			}



			$goodDataInfo{$currentNode}{$epoch}{$channel}=$data;

			#if the epoch is not in the database already add it
			if($epoch != $lastEpoch){

				if($nodeStarts{$currentNode}==undef){
					if($currentNode==0 || $currentNode==2 || $currentNode==3){
						$lastTime=$node023Start;
					}else{
						$lastTime=$node456Start;
					}
					$nodeStarts{$currentNode}=1;
				}

				print "LastTime:$lastTime\n";

				#insert epoch into db with time
				my $query ="INSERT IGNORE INTO HBEF_epoch (node, epoch, time, isInferred) VALUES ($currentNode, $epoch, ADDTIME('$lastTime', '1:0:0'),1)";
				print $query . "\n";
				my $sth = $dbh->prepare($query);
				my $execute = $sth->execute();

				#get id of last insert
				$epochID = $dbh->{ q{mysql_insertid}};

				my $query = "SELECT TIME FROM HBEF_epoch WHERE epochID =$epochID";
				print $query . "\n";
				my $sth = $dbh->prepare($query);
				$sth->execute();

				$sth->bind_columns(undef, \$lastTime);
				$sth->fetch();

				#record all new ids to process temps and sonar readings
				if($currentNode==0 || $currentNode==2 || $currentNode==3){
					push(@newEpochs, $epochID);
				}
			}

			$lastEpoch=$epoch;

			#insert into raw backlog table
			my $query ="INSERT INTO HBEF_backlogData (epochID, sensor, data) VALUES ($epochID, $channel, $data)";
			print $query . "\n";
			my $sth = $dbh->prepare($query);
			$sth->execute();

			#process all info and put into processed table
			if($channel == 6){
				my $calid = sprintf("SELECT CALID FROM %s_CALIBRATION WHERE mote=$currentNode AND modality='voltage'", $location );
				my $ans= &processVoltage($location, $calid, $data);
				if($ans !=0){

					#insert into DB
					my $query ="INSERT INTO HBEF_processedData (epochID, implementationID, data, transformID) VALUES ($epochID, 6, $ans, 1)";
					print $query . "\n";
					my $sth = $dbh->prepare($query);
					$sth->execute();
				}
			}elsif($channel == 3 || $channel ==4){
				my $calid = sprintf("SELECT CALID FROM %s_CALIBRATION WHERE mote=$currentNode AND modality='soil'", $location );
				my $ans= &processSoil($location, $calid, $data);
				if($ans !=0){

					#insert into DB
					my $query ="INSERT INTO HBEF_processedData (epochID, implementationID, data, transformID) VALUES ($epochID, $channel, $ans, 4)";
					print $query . "\n";
					my $sth = $dbh->prepare($query);
					$sth->execute();
				}
			}elsif($channel == 1 || $channel == 2){
				my $calid = sprintf("SELECT CALID FROM %s_CALIBRATION WHERE mote=$currentNode AND modality='par'", $location );
				my $ans= &processPar($location, $calid, $data);
				if($ans !=0){

					#insert into DB
					my $query ="INSERT INTO HBEF_processedData (epochID,
implementationID, data, transformID) VALUES ($epochID, $channel, $ans, 5)";
					print $query . "\n";
					my $sth = $dbh->prepare($query);
					$sth->execute();
				}

			}
		}
	}

	close FILE;
}

my %epochTemps;

#TEMP

foreach my $epochID (@newEpochs){

	#get temp vals from database
	my $query = "SELECT HBEF_epoch.node, HBEF_epoch.epoch, HBEF_backlogData.data FROM HBEF_backlogData, HBEF_epoch WHERE HBEF_backlogData.sensor= 5 AND HBEF_backlogData.epochID=$epochID AND HBEF_epoch.epochID=$epochID";
	my $sth = $dbh->prepare($query);
	$sth->execute();
	print $query . "\n";

	my $node;
	my $data;
	my $epoch;
	$sth->bind_columns(undef, \$node, \$epoch, \$data);
	$sth->fetch();
	$epochTemps{$node}{$epoch}=$data;
	print "Raw temp is:$data \n";

	if(defined($data)){
	#insert into DB
		my $convertedTemps = convert_temp_c($epochTemps{$node}{$epoch});
		print "Converted is:$convertedTemps\n";
		my $query ="INSERT INTO HBEF_processedData (epochID, implementationID, data, transformID) VALUES ($epochID, 5, $convertedTemps, 3)";
		my $sth = $dbh->prepare($query);
		$sth->execute();
		print $query . "\n";
	}
	#Sonar Data

	#get from database
	$query = "SELECT HBEF_epoch.node, HBEF_epoch.epoch, HBEF_backlogData.data FROM HBEF_backlogData, HBEF_epoch WHERE HBEF_backlogData.sensor= 0 AND HBEF_backlogData.epochID=$epochID AND HBEF_epoch.epochID=$epochID";
	my $sth = $dbh->prepare($query);
	$sth->execute();
	print $query . "\n";

	undef($data);
	$sth->bind_columns(undef, \$node, \$epoch, \$data);
	$sth->fetch();

	print "Raw sonar is:$data\n";

	if(defined($data)){
		my $calid = sprintf("SELECT CALID FROM %s_CALIBRATION WHERE mote=$node AND modality='snowdepth'", $location );
		my $ans=&meters_to_inches(&processSnowDepth($location, $calid, $epochTemps{$node}{$epoch}, $data));
		print "Snow Depth is:$ans" . "\n";

		if($ans !=0){

			#insert into DB
			my $query ="INSERT INTO HBEF_processedData (epochID,
implementationID, data, transformID) VALUES ($epochID, 0, $ans, 2)";
			my $sth = $dbh->prepare($query);
			$sth->execute();
			print $query . "\n";
		}
	}
}
