<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>Snowcloud Mammoth</title>
        <link href="snowcloud.css" rel="stylesheet" type="text/css" />
        <link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.16.custom.css" type="text/css" media="all" />
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js" type="text/javascript"></script>
        <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js" type="text/javascript"></script>
        <script src="js/jquery-ui-timepicker-addon.js" type="text/javascript"></script>
        <script type="text/javascript" src="js/highcharts.js"></script>
        <script type="text/javascript" src="js/modules/exporting.js"></script>

        <script>
            $(function() {
                $.datepicker.setDefaults($.datepicker.regional['']);
                $('#starttime').datetimepicker({
                    dateFormat: 'yy-mm-dd',
                    timeFormat: 'hh:mm:ss',
                });
            });
            $(function() {
                $.datepicker.setDefaults($.datepicker.regional['']);
                $('#endtime').datetimepicker({
                    dateFormat: 'yy-mm-dd',
                    timeFormat: 'hh:mm:ss',
                });
            });
        </script>
    </head>
    <body>
        <div class="wrapper">
            <h1 style="margin-bottom:0px;" >Snowcloud Mammoth</h1>
            <a href="index.php" class="topLink">Processed Data</a><span style="font-size:10px; font-weight:bold;"> | </span><a href="rawIndex.php" class="topLink">Raw Data</a>    
