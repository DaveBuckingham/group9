<?php

$starttime = $_POST["starttime"];
$endtime = $_POST["endtime"];
$towers = $_POST["towers"];
$sensors = $_POST["sensors"];
$starttime = htmlentities($starttime, ENT_QUOTES);
$endtime = htmlentities($endtime, ENT_QUOTES);


$sensorcount = count($sensors);
$towercount = count($towers);
$querynodes = "";
/*if ($towercount != 0) {
    $querynodes = 'WHERE (fldMote = ' . $towers[0] . '';
    for ($i = 1; $i < $towercount; $i++) {
        $querynodes .= ' OR fldMote = ' . $towers[$i] . '';
    }
    $querynodes .= ')';
    if ($sensorcount != 0) {
        $querynodes .= ' AND (fldChannel = ' . $sensors[0] . '';
        for ($i = 1; $i < $sensorcount; $i++) {
            $querynodes .= ' OR fldChannel = ' . $sensors[$i] . '';
        }
        $querynodes .= ')';
    }
}
if ($starttime != '' || $endtime != '') {
    if ($endtime == '') {
        $endtime = '3000-12-31 12:59:59';
    }
    if ($querynodes == '') {
        $querynodes .= ' WHERE (fldTimestamp BETWEEN \'' . $starttime . '\' AND \'' . $endtime . '\')';
    } else {
        $querynodes .= ' AND (fldTimestamp BETWEEN \'' . $starttime . '\' AND \'' . $endtime . '\')';
    }
}

$query = '
	SELECT fldMote, fldChannel, fldData, fldTimestamp, 
	FROM group9_rawData ' . $querynodes . '
	GROUP BY fldEpoch, fldChannel
	ORDER BY fldTimestamp, fldMote, fldChannel';
 */?>

<?php
/*$query = 'SELECT fldMote, fldChannel, fldData, fldTimestamp '
        . 'FROM group9_rawData WHERE fldTimestamp BETWEEN 2013-11-15 05:00:00 '
        . 'AND 2013-11-17 05:00:00 GROUP BY fldEpoch, fldChannel '
        . 'ORDER BY fldTimestamp, fldMote, fldChannel;';*/

$query = 'SELECT * FROM group9_rawData;';
?>
