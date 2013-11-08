#!/usr/bin/perl
#Written By: Jonathan Russo

#This script contains a variety of functions that are used by the various number of scripts in this directory


my %coefficients;
$coefficients{'snowDepth'}{0}{'a'}=0.00000212728728432416;
$coefficients{'snowDepth'}{0}{'b'}=0.000187182045706998;
$coefficients{'snowDepth'}{2}{'a'}=0.00000220087256118367;
$coefficients{'snowDepth'}{2}{'b'}=0.0000927979802983521;
$coefficients{'snowDepth'}{3}{'a'}=0.00000221363712365364;
$coefficients{'snowDepth'}{3}{'b'}=0.000119252362141297;
$coefficients{'voltage'}{0}{'a'}=0.0066287679;
$coefficients{'voltage'}{0}{'b'}=0.4405636608;
$coefficients{'voltage'}{2}{'a'}=0.0066975526;
$coefficients{'voltage'}{2}{'b'}=-0.2296411666;
$coefficients{'voltage'}{3}{'a'}=0.0072449851;
$coefficients{'voltage'}{3}{'b'}=-0.2042734816;
$coefficients{'soil'}{'a'}=0.0005;
$coefficients{'soil'}{'b'}=-0.2663;
$coefficients{'par'}{'a'}=-0.7;
$coefficients{'par'}{'b'}=.0066;

my %dis2Ground;
$dis2Ground{0}=2.238375;
$dis2Ground{2}=2.339975;
$dis2Ground{3}=2.25425;

sub connectToDatabase{
	my $database = shift;
	my $platform = "mysql";
	my $host = "localhost";
	my $port = "3306";
	my $user = "snowcloud_admin";					
	my $pw = "Yq3:1GL8";
	
	my $dbh = DBI->connect("DBI:$platform:$database:$port;host=$host", $user, $pw) || die "Could not connect to database: $DBI::errstr";
	return $dbh;
}
sub getEpochId{
	my $n = shift;
	my $e = shift;
	my $dbh =shift;

	my $query = "SELECT epochID FROM epoch WHERE node = $n AND epoch = $e";
	my $sth = $dbh->prepare($query);
	$sth->execute();

	my $epochID;
	$sth->bind_columns(undef, \$epochID);
					
	$sth->fetch();
	return $epochID;
}

sub findMedian{
	@_ == 1 or die ('Sub usage: $median = median(\@array);'); 
	my ($array_ref) = @_; 
	my $count = scalar @$array_ref; 
	
	# Sort a COPY of the array, leaving the original untouched 
	my @array = sort { $a <=> $b } @$array_ref; 
	if ($count % 2) { 
		return $array[int($count/2)]; 
	} else { 
		return ($array[$count/2] + $array[$count/2 - 1]) / 2; 
	} 
} 

sub average
{
    my $arrayRef = shift;
    my @array =@$arrayRef;
    my	$total = @array;
    return (sum(@array)/$total); 
}

sub convert_temp_c
{
    my $temp = shift;
    return -40 + .01 * $temp;
}

sub convert_temp_c{
    my $temp = shift;
    return -40 + .01 * $temp;
}

sub speed_of_sound{
    my $temp = shift;
    return 331.3 * (sqrt (1 + ($temp / 273.15)));
}

sub meters_to_inches{
    my $meters = shift;
    return $meters * 39.3700787;
}

sub processVoltage{
	my $node = shift;
	my $medADC = shift;
	
	my $ans=($coefficients{'voltage'}{$node}{'a'}*$medADC)+$coefficients{'voltage'}{$node}{'b'};
	return $ans;
}

sub processSoil{
	my $medADC =shift;

	my $ans=($coefficients{'soil'}{'a'}*$medADC)+$coefficients{'soil'}{'b'};
	return $ans;
}

sub processPar{
	my $medADC=shift;
	
	my $ans=($medADC-$coefficients{'par'}{'a'})/$coefficients{'par'}{'b'};
	return $ans;
}

sub processSnowDepth{
	my $node = shift;
	my $temp= shift;
	my $medADC = shift;

	my $equationAns = ($coefficients{'snowDepth'}{$node}{'a'}*$medADC)+$coefficients{'snowDepth'}{$node}{'b'};

	my $timeOfFlight = $equationAns * &speed_of_sound(convert_temp_c($temp));	
	
	return $dis2Ground{$node} - $timeOfFlight; 
}

1;
