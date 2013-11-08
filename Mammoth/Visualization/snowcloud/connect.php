<?php

$as = "";
$hostname = 'cemsdb.cems.uvm.edu';
$user = 'snowcloud_user';
$pass = '1pY+865D';
$dbase = 'snowcloud';
$connection = mysql_connect("$hostname", "$user", "$pass")
        or die("Can't connect to MySQL");
$db = mysql_select_db($dbase, $connection) or die("Can't select database.");
?>
