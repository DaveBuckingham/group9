<?php
    // Graphs raw data all modalities on single graph
    include('queryRawData.php');

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



            $node = $row["fldMote"];

            if ($row["fldChannel"] == 0) {
                array_push($snowData["$node"], array($date, $row["fldData"]));
            } elseif ($row["fldChannel"] == 1) {
                array_push($brainPARData["$node"], array($date, $row["fldData"]));
            } elseif ($row["fldChannel"] == 5) {
                array_push($temperatureData["$node"], array($date, $row["fldData"]));
            } elseif ($row["fldChannel"] == 6) {
                array_push($voltageData["$node"], array($date, $row["fldData"]));
            } elseif ($row["fldChannel"] == 2) {
                array_push($groundPARData["$node"], array($date, $row["fldData"]));
            } elseif ($row["fldChannel"] == 3) {
                array_push($soil1Data["$node"], array($date, $row["fldData"]));
            } elseif ($row["fldChannel"] == 4) {
                array_push($soil2Data["$node"], array($date, $row["fldData"]));
            }
        }

        if (isset($_POST["sensors"])) {

            echo '
<script type="text/javascript">
var chart;
$(document).ready(function() {
	chartRaw = new Highcharts.Chart({
		chart: {
			renderTo: \'containerRaw\',
			defaultSeriesType: \'line\',
			marginRight: 130,
			marginBottom: 25,
			zoomType: \'x\'
		},
		title: {
			text: \'Raw Data\',
			x: -20 //center
		},
		subtitle: {
			text: \'\',
			x: -20
		},
		xAxis: {
			type: \'datetime\',
			dateTimeLabelFormats: { 
				month: \'%b. %e\',
				year: \'%b\',
				hour: \'%l:%M%P\'
			}

		},
		yAxis: {
			title: {
				text: \'Raw Data (adc counts)\'
			},
			plotLines: [{
				value: 0,
				width: 1,
				color: \'#808080\'
			}]
		},
    		credits: {
        		enabled: false
    		},		
		tooltip: {
		formatter: function() {
					return \'<b>\'+ this.series.name +\'</b><br/>\'+
					Highcharts.dateFormat(\'%b. %e %l:%M%P\' , this.x) +\'<br/>\'+ this.y;
			}
		},

		legend: {
			layout: \'vertical\',
			align: \'right\',
			verticalAlign: \'top\',
			x: -10,
			y: 100,
			borderWidth: 0
		},
		series: [
			';
            $i = 0;
            foreach ($snowData as $node => $n) {

                if (!empty($n)) {

                    $tower = nodeTower($node);

                    $jsonData = json_encode($n, JSON_NUMERIC_CHECK);
                    if ($i > 0) {
                        echo ',';
                    }
                    echo '{
			name: \'Tower ' . $tower . ' Snow Depth\',
			data: ' . $jsonData . '
			} ';
                    $i++;
                }
            }

            foreach ($brainPARData as $node => $n) {

                if (!empty($n)) {
                    $tower = nodeTower($node);
                    $jsonData = json_encode($n, JSON_NUMERIC_CHECK);
                    if ($i > 0) {
                        echo ',';
                    }
                    echo '{
			name: \'Tower ' . $tower . ' Brain PAR\',
			data: ' . $jsonData . '
			} ';
                    $i++;
                }
            }

            foreach ($temperatureData as $node => $n) {

                if (!empty($n)) {
                    $tower = nodeTower($node);
                    $jsonData = json_encode($n, JSON_NUMERIC_CHECK);
                    if ($i > 0) {
                        echo ',';
                    }
                    echo '{
			name: \'Tower ' . $tower . ' Temperature\',
			data: ' . $jsonData . '
			} ';
                    $i++;
                }
            }

            foreach ($voltageData as $node => $n) {

                if (!empty($n)) {
                    $tower = nodeTower($node);
                    $jsonData = json_encode($n, JSON_NUMERIC_CHECK);
                    if ($i > 0) {
                        echo ',';
                    }
                    echo '{
			name: \'Tower ' . $tower . ' Voltage\',
			data: ' . $jsonData . '
			} ';
                    $i++;
                }
            }

            foreach ($groundPARData as $node => $n) {

                if (!empty($n)) {
                    $tower = nodeTower($node);
                    $jsonData = json_encode($n, JSON_NUMERIC_CHECK);
                    if ($i > 0) {
                        echo ',';
                    }
                    echo '{
			name: \'Tower ' . $tower . ' Ground PAR\',
			data: ' . $jsonData . '
			} ';
                    $i++;
                }
            }

            foreach ($soil1Data as $node => $n) {

                if (!empty($n)) {
                    $tower = nodeTower($node);
                    $jsonData = json_encode($n, JSON_NUMERIC_CHECK);
                    if ($i > 0) {
                        echo ',';
                    }
                    echo '{
			name: \'Tower ' . $tower . ' Soil 1\',
			data: ' . $jsonData . '
			} ';
                    $i++;
                }
            }

            foreach ($soil2Data as $node => $n) {

                if (!empty($n)) {
                    $tower = nodeTower($node);
                    $jsonData = json_encode($n, JSON_NUMERIC_CHECK);
                    if ($i > 0) {
                        echo ',';
                    }
                    echo '{
			name: \'Tower ' . $tower . ' Soil 2\',
			data: ' . $jsonData . '
			} ';
                    $i++;
                }
            }







            echo '
		]
	});
});

		</script>';
            echo '<div id="containerRaw" style="width: 1000px; height: 400px; margin: 50px auto"></div>';
        }
    }
    else
        echo 'No raw data available for your selection.';

?>
