<?php
    //Loads processed data arrays from DB.
    //Calls graph() function for selected modalities.
    include('queryProcessedData.php');

    $result = mysql_query("$query") or die("Error: " . mysql_error());
    if (mysql_num_rows($result) > 0) {




        $snowData = array(0 => array(), 2 => array(), 3 => array());
        $brainPARData = array(0 => array(), 2 => array(), 3 => array());
        $temperatureData = array(0 => array(), 2 => array(), 3 => array());
        $voltageData = array(0 => array(), 2 => array(), 3 => array());

        $groundPARData = array(4 => array(), 5 => array(), 6 => array());
        $soil1Data = array(4 => array(), 5 => array(), 6 => array());
        $soil2Data = array(4 => array(), 5 => array(), 6 => array());
        while ($row = mysql_fetch_array($result)) {
            date_default_timezone_set('UTC');
            $date = (strtotime($row['time']) * 1000) - (strtotime('02-01-1970 00:00:00') * 1000);



            $node = $row["node"];

            if ($row["implementationID"] == 0) {
                array_push($snowData["$node"], array($date, $row["data"]));
            } elseif ($row["implementationID"] == 1) {
                array_push($brainPARData["$node"], array($date, $row["data"]));
            } elseif ($row["implementationID"] == 5) {
                array_push($temperatureData["$node"], array($date, $row["data"]));
            } elseif ($row["implementationID"] == 6) {
                array_push($voltageData["$node"], array($date, $row["data"]));
            } elseif ($row["implementationID"] == 2) {
                array_push($groundPARData["$node"], array($date, $row["data"]));
            } elseif ($row["implementationID"] == 3) {
                array_push($soil1Data["$node"], array($date, $row["data"]));
            } elseif ($row["implementationID"] == 4) {
                array_push($soil2Data["$node"], array($date, $row["data"]));
            }
        }

        if (isset($_POST["sensors"])) {
            if (in_array(0, $_POST["sensors"])) {

                graph($chartNumber = 'chart0', $container = 'container0', $title = 'Snow Depth', $units = 'in', $data = $snowData);
            }

            if (in_array(1, $_POST["sensors"])) {
                graph($chartNumber = 'chart1', $container = 'container1', $title = 'Sky PAR', $units = 'μmoles', $data = $brainPARData);
            }

            if (in_array(2, $_POST["sensors"])) {
                graph($chartNumber = 'chart2', $container = 'container2', $title = 'Ground PAR', $units = 'μmoles', $data = $groundPARData);
            }

            if (in_array(3, $_POST["sensors"])) {
                graph($chartNumber = 'chart3', $container = 'container3', $title = 'Soil Moisture 1', $units = '%', $data = $soil1Data);
            }

            if (in_array(4, $_POST["sensors"])) {
                graph($chartNumber = 'chart4', $container = 'container4', $title = 'Soil Moisture 2', $units = '%', $data = $soil2Data);
            }
            
            if (in_array(5, $_POST["sensors"])) {
                graph($chartNumber = 'chart5', $container = 'container5', $title = 'Air Temp', $units = 'C', $data = $temperatureData);
            }

            if (in_array(6, $_POST["sensors"])) {
                graph($chartNumber = 'chart6', $container = 'container6', $title = 'Voltage', $units = 'V', $data = $voltageData);
            }
        }
    }
    else
        echo"<div class='plot'>No data available for your selection.</div>";



?>
