<?php
//Functions:   graph(), drawTable(), and createCSV()

//Graphs Processed data. Creates individual sensor graphs of processed data. Called on prepareGraphs.php
//Raw data graphed using graphRaw.php
function graph($chartNumber, $container, $title, $units, $data) {
echo '
<script type="text/javascript">
var chart;
$(document).ready(function() {
	'.$chartNumber.' = new Highcharts.Chart({
		chart: {
			renderTo: \''.$container.'\',
			defaultSeriesType: \'line\',
			marginRight: 130,
			marginBottom: 25,
			zoomType: \'x\'
		},
		title: {
			text: \''.$title.'\',
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
				year: \'%b\'
			}

		},
		yAxis: {
			title: {
				text: \''.$title.' ('.$units.')\'
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
$n = 0;
foreach ($data as $node => $n) {

    if (!empty($n)) {
        $tower = nodeTower($node);
        $jsonData = json_encode($n, JSON_NUMERIC_CHECK);
        if ($i > 0) {
            echo ',';
        }
        echo '{
			name: \'Tower ' . $tower . '\',
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
echo '<div id="'.$container.'" style="width: 1000px; height: 400px; margin: 50px auto"></div>';
}


function drawTable($processed) {
    echo'<table><tr><th>Tower</th><th>Sensor</th><th>Data</th><th>Time</th></tr>';

    if ($processed) {
        include('queryProcessedData.php');
    }
    else
        include('queryRawData.php');

    $result = mysql_query("$query") or die("Error: " . mysql_error());
    while ($row = mysql_fetch_array($result)) {

        $tower = $row["towerID"];
        if ($processed) {
            $sensor = $row["implementationID"];
            $data = $row["data"];
        } else {
            $sensor = $row["sensor"];
            $data = $row["avgdata"];
        }
        $time = $row["time"];


        echo "<tr><td>$tower</td><td>$sensor</td><td>$data</td><td>$time</td></tr>";
    }

    echo '</table>';
}

function createCSV($processed) {
    if ($processed) {
        include('queryProcessedData.php');
    }
    else
        include('queryRawData.php');

    $result = mysql_query("$query") or die("Error: " . mysql_error());
    $num_fields = mysql_num_fields($result);
    $headers = array();
    for ($i = 0; $i < $num_fields; $i++) {
        $headers[] = mysql_field_name($result, $i);
    }
    $fp = fopen('snowcloud_data.csv', 'w');
    if ($fp && $result) {
        fputcsv($fp, $headers);
        while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
            fputcsv($fp, $row);
        }
    }
}
//  for mapping node to tower (used only in graph)
function nodeTower($node) {
    if ($node == 0 || $node == 4) {
        $tower = 1;
    } elseif ($node == 2 || $node == 5) {
        $tower = 2;
    } elseif ($node == 3 || $node == 6) {
        $tower = 3;
    }
    return $tower;
}
?>
