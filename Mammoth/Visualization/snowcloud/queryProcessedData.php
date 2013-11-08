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
            $querynodes .= ' AND (implementationID = ' . $sensors[0] . '';
            for ($i = 1; $i < $sensorcount; $i++) {
                $querynodes .= ' OR implementationID = ' . $sensors[$i] . '';
            }
            $querynodes .= ')';
        }
    }
    if ($starttime != '' || $endtime != '') {
        if ($endtime == '') {
            $endtime = '3000-12-31 12:59:59';
        }
        if ($querynodes == '') {
            $querynodes .= ' WHERE (time BETWEEN \'' . $starttime . '\' AND \'' . $endtime . '\')';
        } else {
            $querynodes .= ' AND (time BETWEEN \'' . $starttime . '\' AND \'' . $endtime . '\')';
        }
    }

    $query = '
	SELECT node, implementationID, data, time, towerID
	FROM processedData JOIN epoch ON processedData.epochID = epoch.epochID JOIN nodes ON epoch.node = nodes.ID
	' . $querynodes . '
	ORDER BY time, node';
?>
