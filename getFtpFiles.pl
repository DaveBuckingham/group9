#!/usr/bin/perl

use strict;
use Net::FTP;

# require 'databaseWrite.pl';

my $host = "65.183.149.248";
my $user = "group9";
my $password = "snowcloud";

my $f = Net::FTP->new($host) or die "Can't open $host\n";
$f->login($user, $password) or die "Can't log $user in\n";

my $dir = "snowcloud_data";

$f->cwd($dir) or die "Can't cwd to $dir\n";

# my $file_to_get = "sample_out.dat";
# $f->get($file_to_get) or die "Can't get $file_to_get from $dir\n";

$, = "\n";
my @files = $f->ls;
foreach (@files) {
	if ($_ =~ /$.dat/) {
		$f->get($_) or die "Can't get $_ from $dir\n";
	}
}

my $output;
foreach (<*.dat>) {
	 $output = `./databaseWrite.pl $_`;
} 	 print $output;