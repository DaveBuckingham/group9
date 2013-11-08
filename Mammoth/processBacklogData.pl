#!/usr/bin/perl

#Snowcloud Project 
#Coded By: Jonathan Russo

#This script will pull the backlog data from the database, process it and put it back into a new table in the database.

use strict;
use List::Util qw(sum);
use DBI;
use DBD::mysql;

#get functions
require 'functions.pl';

#connect to database
my $dbh= connectToDatabase('snowcloud');

#initialize variables
my %epochTemps;
my %epochSonar;
my %epochVoltage;

##################################
#Pull neccesary data from database
##################################

#TEMP 

#get temp vals from database
my $query = "SELECT epoch.epochID, epoch.node, epoch.epoch, backlogData.data FROM backlogData, epoch WHERE backlogData.sensor= 5 AND backlogData.epochID=epoch.epochID ORDER BY epoch.node, epoch.epoch";
my $sth = $dbh->prepare($query);
$sth->execute();

my $node; 
my $data;
my $epoch;
my $epochID;
$sth->bind_columns(undef, \$epochID, \$node, \$epoch, \$data);
					
while($sth->fetch()){
	$epochTemps{$node}{$epoch}=$data;

	#insert into DB
	my $convertedTemps = convert_temp_c($epochTemps{$node}{$epoch});
	my $query ="INSERT INTO processedData (epochID, implementationID, 
data, transformID) VALUES ($epochID, 5, $convertedTemps, 3)";
	my $sth = $dbh->prepare($query);
	$sth->execute();
}


#Sonar Data

#get from database
$query = "SELECT epoch.epochID, epoch.node, epoch.epoch, backlogData.data FROM backlogData, epoch WHERE backlogData.sensor= 0 AND backlogData.epochID=epoch.epochID ORDER BY epoch.node, epoch.epoch";
my $sth = $dbh->prepare($query);
$sth->execute();

my $node; 
my $data;
my $epoch;
my $epochID;
$sth->bind_columns(undef, \$epochID, \$node, \$epoch, \$data);
					
while($sth->fetch()){
	my $ans=&meters_to_inches(&processSnowDepth($node, $epochTemps{$node}{$epoch}, $data));
	#print $ans . "\n";
	if($ans !=0){		
		
		#insert into DB
		my $query ="INSERT INTO processedData (epochID, 
implementationID, data, transformID) VALUES ($epochID, 0, $ans, 2)";
		my $sth = $dbh->prepare($query);
		$sth->execute();
	}

}


#Voltage Data

#get from database
$query = "SELECT epoch.epochID, epoch.node, epoch.epoch, backlogData.data FROM backlogData, epoch WHERE backlogData.sensor= 6 AND backlogData.epochID=epoch.epochID ORDER BY epoch.node, epoch.epoch";
my $sth = $dbh->prepare($query);
$sth->execute();

my $node; 
my $data;
my $epoch;
my $epochID;
$sth->bind_columns(undef, \$epochID, \$node, \$epoch, \$data);
					
while($sth->fetch()){
	my $ans= &processVoltage($node, $data);
		if($ans !=0){		
			
			#insert into DB
			my $query ="INSERT INTO processedData (epochID, 
implementationID, data, transformID) VALUES ($epochID, 6, $ans, 1)";
			my $sth = $dbh->prepare($query);
			$sth->execute();
		}
}

#Soil Data

#get from database
$query = "SELECT epoch.epochID, epoch.node, epoch.epoch, backlogData.data, backlogData.sensor FROM backlogData, epoch WHERE (backlogData.sensor= 3 OR backlogData.sensor=4) AND backlogData.epochID=epoch.epochID ORDER BY epoch.node, epoch.epoch";
my $sth = $dbh->prepare($query);
$sth->execute();

my $node; 
my $data;
my $epoch;
my $epochID;
my $sensor;
$sth->bind_columns(undef, \$epochID, \$node, \$epoch, \$data, \$sensor);
					
while($sth->fetch()){
	my $ans= &processSoil($data);
		if($ans !=0){		
			
			#insert into DB
			my $query ="INSERT INTO processedData (epochID, 
implementationID, data, transformID) VALUES ($epochID, $sensor, $ans, 4)";
			my $sth = $dbh->prepare($query);
			$sth->execute();
		}
}

#Par Data

#get from database
$query = "SELECT epoch.epochID, epoch.node, epoch.epoch, backlogData.data, backlogData.sensor FROM backlogData, epoch WHERE (backlogData.sensor= 1 OR backlogData.sensor=2) AND backlogData.epochID=epoch.epochID ORDER BY epoch.node, epoch.epoch";
my $sth = $dbh->prepare($query);
$sth->execute();

my $node; 
my $data;
my $epoch;
my $epochID;
my $sensor;
$sth->bind_columns(undef, \$epochID, \$node, \$epoch, \$data, \$sensor);

while($sth->fetch()){
	my $ans= &processPar($data);
		if($ans !=0){		
			
			#insert into DB
			my $query ="INSERT INTO processedData (epochID, 
implementationID, data, transformID) VALUES ($epochID, $sensor, $ans, 5)";
			my $sth = $dbh->prepare($query);
			$sth->execute();
		}
}
