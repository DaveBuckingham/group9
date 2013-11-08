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
if ($towercount != 0) {
    $querynodes = 'WHERE (nodes.towerID = ' . $towers[0] . '';
    for ($i = 1; $i < $towercount; $i++) {
        $querynodes .= ' OR nodes.towerID = ' . $towers[$i] . '';
    }
    $querynodes .= ')';
    if ($sensorcount != 0) {
        $querynodes .= ' AND (sensor = ' . $sensors[0] . '';
        for ($i = 1; $i < $sensorcount; $i++) {
            $querynodes .= ' OR sensor = ' . $sensors[$i] . '';
        }
        $querynodes .= ')';
    }
}
if ($starttime != '' || $endtime != '') {
    if ($endtime == '') {
        $endtime = '3000-12-31 12:59:59';
    }
    if ($querynodes == '') {
        $querynodes .= ' WHERE (epoch.time BETWEEN \'' . $starttime . '\' AND \'' . $endtime . '\')';
    } else {
        $querynodes .= ' AND (epoch.time BETWEEN \'' . $starttime . '\' AND \'' . $endtime . '\')';
    }
}

$query = '
	SELECT epoch.node, sensor, AVG(data) AS avgdata, epoch.time, towerID
	FROM backlogData JOIN epoch ON backlogData.epochID = epoch.epochID JOIN nodes ON epoch.node = nodes.ID 
	' . $querynodes . '
	GROUP BY epoch.epochID, sensor
	ORDER BY time, epoch.node, sensor';
?>
