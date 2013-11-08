<?php

/* Main RAW Interface*/
include("connect.php");  //connects once to the database
include("functions.php"); //functions for creating plots, csv, and table.
include("template_header.php");  //includes header html and javascript for date picker and High Charts.
echo'
        <form id="snowcloudinterface" name="snowcloudinterface" method="post" action="' . $_SERVER['PHP_SELF'] . '">
	<table id="rawIndex">
<tr><th style="width:69px;">Tower #</th><th style="width:69px;">Longitude</th><th style="width:69px;">Latitude</th><th style="width:345px;">Sensors</th></tr>
';
/* Querys Towers to allow user selection, remembers past selections durring session */
$query1 = "
      SELECT *
      FROM nodes JOIN tower ON nodes.towerID = tower.towerID";

$result = mysql_query("$query1") or die("Error: " . mysql_error());
$towercount = array(0, 0, 0, 0);
$count = 0;

while ($row = mysql_fetch_array($result)) {

    $towerID = $row["towerID"];
    $type = $row["type"];
    $longitude = $row["long"];
    $latitude = $row["lat"];

    if ($towercount[$towerID] == 0 && $count == 0) {

        echo '<tr><td><input type="checkbox" name="towers[]" value="' . $towerID . '" id="tower' . $towerID . '"';
        if (isset($_POST["towers"]) && in_array($towerID, $_POST["towers"]))
            echo ' checked="checked"';
        echo'/><label for="tower' . $towerID . '">Tower ' . $towerID . '</label></td><td>' . $longitude . '</td><td>' . $latitude . '</td>';
        $towercount[$towerID] = 1;
        $count++;

        echo '<td style="padding:20px;" rowspan="3"><label for="sensor0">Sonar:</label><input type=checkbox name="sensors[]" value="0" id="sensor0"';
        if (isset($_POST["sensors"]) && in_array(0, $_POST["sensors"]))
            echo ' checked="checked"';
        echo'/> <label for="sensor1">Sky PAR:</label><input type=checkbox name="sensors[]" value="1" id="sensor1"';
        if (isset($_POST["sensors"]) && in_array(1, $_POST["sensors"]))
            echo ' checked="checked"';
        echo'/> <label for="sensor5">Air Temp:</label><input type=checkbox name="sensors[]" value="5" id="sensor5"';
        if (isset($_POST["sensors"]) && in_array(5, $_POST["sensors"]))
            echo ' checked="checked"';
        echo'/> <label for="sensor6">Voltage:</label><input type=checkbox name="sensors[]" value="6" id="sensor6"';
        if (isset($_POST["sensors"]) && in_array(6, $_POST["sensors"]))
            echo ' checked="checked"';
        echo'/>
        <br/><br/><br/><label for="sensor2">Ground PAR:</label><input type=checkbox name="sensors[]" value="2" id="sensor2"';
        if (isset($_POST["sensors"]) && in_array(2, $_POST["sensors"]))
            echo ' checked="checked"';
        echo'/> <label for="sensor3">Soil Moisture 1:</label><input type=checkbox name="sensors[]" value="3" id="sensor3"';
        if (isset($_POST["sensors"]) && in_array(3, $_POST["sensors"]))
            echo ' checked="checked"';
        echo'/> <label for="sensor4">Soil Moisture 2:</label><input type=checkbox name="sensors[]" value="4" id="sensor4"';
        if (isset($_POST["sensors"]) && in_array(4, $_POST["sensors"]))
            echo ' checked="checked"';
        echo'/>            
</td></tr>';
    }
    else if ($towercount[$towerID] == 0) {

        echo '<tr><td><input type="checkbox" name="towers[]" value="' . $towerID . '" id="tower' . $towerID . '"';
        if (isset($_POST["towers"]) && in_array($towerID, $_POST["towers"]))
            echo ' checked="checked"';
        echo'/><label for="tower' . $towerID . '">Tower ' . $towerID . '</label></td><td>' . $longitude . '</td><td>' . $latitude . '</td></tr>';
        $towercount[$towerID] = 1;
    }
}
echo '<tr><td colspan="4">Start time: <input type="text" name="starttime" id="starttime"';
if (isset($_POST["starttime"]))
    echo ' value="' . $_POST["starttime"] . '"';
echo' /></td></tr><tr><td colspan="4">End time: <input type="text" name="endtime" id="endtime"';
if (isset($_POST["endtime"]))
    echo ' value="' . $_POST["endtime"] . '"';
echo' /></td></tr><tr><td colspan="4"> <label for="plotR">Plot:</label><input type=checkbox name="plotR" value="yes" id="plotR"';
if ($_POST["plotR"] == 'yes')
    echo ' checked="checked"';
echo '/> <label for="csv">CSV:</label><input type=checkbox name="csv" value="yes" id="csv"';
if ($_POST["csv"] == 'yes')
    echo ' checked="checked"';
echo'/> <label for="table">Table:</label><input type=checkbox name="table" value="yes" id="table"';
if ($_POST["table"] == 'yes')
    echo ' checked="checked"';
echo'/></td></tr><tr><td colspan="4"><input type="submit" name="submitted" value="Submit" /><a style="float:right;" href="' . $_SERVER['PHP_SELF'] . '">Reset Fields</a></td></tr></table></form>';
?>
<?php

if ($_POST["plotR"] == 'yes') {
    // Draws single graph of raw data.
    include("graphRaw.php");
}
if (isset($_POST['submitted']) && $_POST["csv"] == 'yes') {
    //Fills snowcloud_data.csv with selected raw data, this file must have proper permissions
    createCSV($processed = false);
    echo "<div class='csv'><a href='snowcloud_data.csv'>Download as CSV</a></div>";
}
if (isset($_POST['submitted']) && $_POST["table"] == 'yes') {
    // Fills HTML table with selected raw data
    drawTable($processed = false);
}
// includes end HTML
include("template_footer.php");
?>
