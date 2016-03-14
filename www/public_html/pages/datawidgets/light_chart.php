


<!-- Chart Code -->


<?php
# We are going to use variables passed from the main page,
# Specifically - Period and Chart

#echo "Second Chart is $chart";
#echo "Second Period is "; 

switch ($period) {
    case "day":
        $sqlperiod = "-1 days";
        break;
    case "week":
        $sqlperiod = "-7 days";
        break;
    case "month":
        $sqlperiod = "-1 months";
        break;
    case "year":
        $sqlperiod =  "-1 years";
        break;
    case "all":
        $sqlperiod =  "-20 years";
        break;
    }


if ($chart == 'line') {
    # Echo back the Javascript code
 
include($_SERVER["DOCUMENT_ROOT"] . "/include/db-connect.php");

// Get Light Data First
$sth = $conn->prepare("SELECT solarradiation, uv, lux, strftime('%s',date)*1000 AS datetime FROM allhivedata WHERE date > datetime('now','$sqlperiod')");
$sth->execute();
$result = $sth->fetchAll(PDO::FETCH_ASSOC);

include($_SERVER["DOCUMENT_ROOT"] . "/include/gettheme.php");

echo "
<!-- Chart Code -->


<script>
$(function () {
    $('#container').highcharts({
        chart: {
            
            zoomType: 'x'
        },
        title: {
            text: '', 
        },
        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: {
                second: '%m-%d<br/>%H:%M:%S',
                minute: '%m-%d<br/>%H:%M',
                hour: '%m-%d<br/>%H:%M',
                day: '<br/>%m-%d',
                week: '<br/>%m-%d',
                month: '%Y-%m',
                year: '%Y'
            }

        },

        rangeSelector: {
                allButtonsEnabled: true,
                selected: 2
            },
           
        yAxis: [{ // Primary yAxis
            labels: {
                format: '{value} wm/2',
                style: {
                    color: Highcharts.getOptions().colors[1]
                }
            },
            title: {
                text: 'SolarRadiation',
                style: {
                    color: Highcharts.getOptions().colors[1]
                }
            }
            

        }, { // Secondary yAxis
            gridLineWidth: 0,
            title: {
                text: 'Lux',
                style: {
                    color: Highcharts.getOptions().colors[0]
                }
            },
            labels: {
                format: '{value} lux',
                style: {
                    color: Highcharts.getOptions().colors[0]
                }
            },
            opposite: true

        }],
        plotOptions: {
            line: {
                dataLabels: {
                    enabled: false
                },
                enableMouseTracking: true
            }
        },
        tooltip: {
            formatter: function () {
                var s = '<b>' + Highcharts.dateFormat('%m/%d %H:%M', this.x) + '</b>';

                $.each(this.points, function () {
                    s += '<br/>' + this.series.name + ': ' +
                        this.y;
                });

                return s;
            },
            shared: true

        },
        series: [{
            type: 'line',
            name: 'Solar Radiation (wm/2)',
            data: ["; foreach($result as $r){echo "[".$r['datetime'].", ".$r['solarradiation']."]".", ";} echo "],
            dashStyle: 'longdash', 
            color: '#FFD700',
        },
        {
           type: 'line',
           name: 'Lux',
           data: ["; foreach($result as $r){echo "[".$r['datetime'].", ".$r['lux']."]".", ";} echo "],
           color: '#000000',
           dashStyle: 'longdash',
           visible: true
        }        
        ]
    });

        Highcharts.getOptions().exporting.buttons.contextButton.menuItems.push({
            text: 'Enlarge Chart',
            onclick: function () {
                centeredPopup('/pages/fullscreen/light.php?chart=line&period=";echo $period; echo"','HiveControl','1200','500','yes')
                return false;
            }
        });
});
</script>";


} elseif ($chart == 'bar') {
    # code...
}



?>


 




