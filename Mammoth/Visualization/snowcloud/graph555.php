<?php
include('template_header.php');
include('connect.php');

    $starttime = $_POST["starttime"];
    $endtime = $_POST["endtime"];
    $nodes = $_POST["nodes"];
    $sensors = $_POST["sensors"];
    $starttime = htmlentities($starttime, ENT_QUOTES);
    $endtime = htmlentities($endtime, ENT_QUOTES);


    $sensorcount = count($sensors);
    $nodecount = count($nodes);
    $querynodes = "";
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
	SELECT count, time
	FROM badData
	' . $querynodes . '
	ORDER BY time';

    $result = mysql_query("$query") or die("Error: " . mysql_error());

    if (mysql_num_rows($result) > 0) {
        $badData = array();
        while ($row = mysql_fetch_array($result)) {
            date_default_timezone_set('UTC');
            $date = (strtotime($row['time']) * 1000) - (strtotime('02-01-1970 00:00:00') * 1000);
            $count = $row["count"];
            array_push($badData, array($date, $count));
        }


        $jsonData = json_encode($badData, JSON_NUMERIC_CHECK);
        echo '
<script type="text/javascript">
var chart;
$(document).ready(function() {
	chart555 = new Highcharts.Chart({
		chart: {
			renderTo: \'container555\',
			defaultSeriesType: \'line\',
			marginRight: 130,
			marginBottom: 25,
			zoomType: \'x\'
		},
		title: {
			text: \'555 Data\',
			x: -20 //center
		},
		subtitle: {
			text: \'\',
			x: -20
		},
		xAxis: {
			type: \'datetime\',
			dateTimeLabelFormats: { 
				month: \'%e. %b\',
				year: \'%b\',
				hour: \'%l:%M %P\'
			}

		},
		yAxis: {
			title: {
				text: \'555 Data (counts)\'
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
			{
			name: \'555 Data\',
			data: ' . $jsonData . '
			}
		]
	});
});

		</script>';
        echo '<div id="container555" style="width: 1000px; height: 400px; margin: 50px auto"></div>';
    }
    else
        echo 'No 555 data available in your selection.';
include('template_footer.php');

?>
