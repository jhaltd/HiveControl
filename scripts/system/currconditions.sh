#!/bin/bash
# Script to gather Current_Conditions to monitor beehives
# see hivecontrol.org
# Author: Ryan Crum
# Version 2019071101

#############################################
# Get Config parameters from DB and set some basics
#############################################
clear

echo "##########################################################"
echo "# Starting HiveControl Current Conditions Collection     #"
echo "##########################################################"
echo "Getting Latest Configurations"
echo ""

SHELL=/bin/bash
/home/HiveControl/scripts/data/hiveconfig.sh


# Set some basics
PATH=/usr/local/sbin:/usr/local/bin:/bin:/sbin:/usr/sbin:/usr/bin:/home/HiveControl/scripts/weather:/home/HiveControl/scripts/system
HOST=`hostname`
#Load the results of the script above

source /home/HiveControl/scripts/hiveconfig.inc
source /home/HiveControl/scripts/data/check.inc
source /home/HiveControl/scripts/data/logger.inc
source /home/HiveControl/scripts/data/cloud.inc


DATE=$(TZ=":$TIMEZONE" date '+%F %T') #For local display in relation to the user's timezone
DATE_UTC=$(TZ=":$UTC" date '+%F %T')  #For when we send to cloud, so we can compare data across the world

echo "##########################################################"


############################################################################################################
# Used to determine if we should run or not - allows us to pause the collection during manipulation
############################################################################################################
if [ $RUN = "no" ]; then
	loglocal "$DATE" MAIN INFO "Execution of main script is disabled - renable in System Commands screen"
	echo "This script has been disabled in the UI, under System Commands"
	echo "Exiting...."
	exit;
fi

####################################################################################
# ------ GET HIVE WEIGHT ----
####################################################################################
	
	if [ $ENABLE_HIVE_WEIGHT_CHK = "yes" ]; then
		echo " --- GETTING WEIGHT ---      "
		HIVEWEIGHTSRC=$($HOMEDIR/scripts/weight/getweight.sh)
		HIVEWEIGHT=$(echo $HIVEWEIGHTSRC |awk '{print $2}')
		HIVERAWWEIGHT=$(echo $HIVEWEIGHTSRC |awk '{print $1}')
		check HIVEWEIGHTSRC
		check HIVEWEIGHT
		check HIVERAWWEIGHT		
	echo "Gross=$HIVERAWWEIGHT, Net=$HIVEWEIGHT "
		#echo "--- WEIGHT DONE ---"
	else
		echo " --- WEIGHT CHECK DISABLED--- 	"
		HIVEWEIGHT="null"
		HIVERAWWEIGHT="null"
	fi
	echo "		"
	echo "##########################################################"
##################################################################
# ------ GET HIVE TEMP ------
##################################################################
	if [ $ENABLE_HIVE_TEMP_CHK = "yes" ]; then
		echo " --- GETTING HIVE TEMP ---	 "
		HIVETEMPSRC=$($HOMEDIR/scripts/temp/gettemp.sh)
		HIVETEMPF=$(echo $HIVETEMPSRC |awk '{print $1}')
		HIVETEMPC=$(echo $HIVETEMPSRC |awk '{print $4}')
		HIVEHUMIDITY=$(echo $HIVETEMPSRC |awk '{print $2}')
		HIVEDEW=$(echo $HIVETEMPSRC |awk '{print $3}')
		echo "Calculated: TEMPF=$HIVETEMPF, TEMPC=$HIVETEMPC, HUMI=$HIVEHUMIDITY"
	else
		echo "--- HIVE TEMP DISABLED ---"
		HIVETEMPF="null"
		HIVETEMPC="null"
		HIVEHUMIDITY="null"
		HIVEDEW="null"
	fi
	#echo "--- TEMP DONE ---"
	echo "		"
	echo "##########################################################"

##########################################################################################
# --------- Get Beecount -------------
##########################################################################################
if [[ $ENABLE_BEECOUNTER = "yes" ]]; then
	echo "--- Counting Bee Flights ---"
	INOUT=$($HOMEDIR/scripts/beecount/countbees.sh)
	#INOUT=$($HOMEDIR/scripts/beecounter/countbees.sh)
	IN_COUNT=$(echo $INOUT | awk -F, '{print $1}')
	OUT_COUNT=$(echo $INOUT | awk -F, '{print $2}')
	check IN_COUNT
	check OUT_COUNT
	echo "IN=$IN_COUNT, OUT=$OUT_COUNT"
	#echo "--- Counting Bee Flights Done ---"
else
	IN_COUNT="null"
	OUT_COUNT="null"
fi
	echo "		"
	echo "##########################################################"


##################################################################
#---------- Get Ambient Weather--------
# Variables come from variable.inc
# Weather Data
##################################################################
	echo "--- Getting Ambient Weather ---"
	WXSOURCE=$($HOMEDIR/scripts/weather/getwx.sh)
	
	WEATHER_STATIONID=$(echo $WXSOURCE | awk -F, '{print $1}')
	OBSERVATIONDATETIME=$(echo $WXSOURCE | awk -F, '{print $2}')
	A_TEMP=$(echo $WXSOURCE | awk -F, '{print $3}')
	B_HUMIDITY=$(echo $WXSOURCE | awk -F, '{print $4}')
	A_DEW=$(echo $WXSOURCE | awk -F, '{print $5}')
	A_TEMP_C=$(echo $WXSOURCE | awk -F, '{print $6}')
	A_WIND_MPH=$(echo $WXSOURCE | awk -F, '{print $7}')
	A_WIND_DIR=$(echo $WXSOURCE | awk -F, '{print $8}')
	wind_degrees=$(echo $WXSOURCE | awk -F, '{print $9}')
	wind_gust_mph=$(echo $WXSOURCE | awk -F, '{print $10}')
	wind_kph=$(echo $WXSOURCE | awk -F, '{print $11}')
	wind_gust_kph=$(echo $WXSOURCE | awk -F, '{print $12}')
	pressure_mb=$(echo $WXSOURCE | awk -F, '{print $13}')
	A_PRES_IN=$(echo $WXSOURCE | awk -F, '{print $14}')
	A_PRES_TREND=$(echo $WXSOURCE | awk -F, '{print $15}')
	weather_dewc=$(echo $WXSOURCE | awk -F, '{print $16}')
	solarradiation=$(echo $WXSOURCE | awk -F, '{print $17}')
	UV=$(echo $WXSOURCE | awk -F, '{print $18}')
	precip_1hr_in=$(echo $WXSOURCE | awk -F, '{print $19}')
	precip_1hr_metric=$(echo $WXSOURCE | awk -F, '{print $20}')
	precip_today_string=$(echo $WXSOURCE | awk -F, '{print $21}')
	precip_today_in=$(echo $WXSOURCE | awk -F, '{print $22}')
	precip_today_metric=$(echo $WXSOURCE | awk -F, '{print $23}')
	
	echo "$WEATHER_STATIONID,'$OBSERVATIONDATETIME', $A_TEMP ,$B_HUMIDITY,$A_DEW,$A_TEMP_C,'$A_WIND_MPH','$A_WIND_DIR','$wind_degrees','$wind_gust_mph','$wind_kph','$wind_gust_kph','$pressure_mb','$A_PRES_IN','$A_PRES_TREND','$weather_dewc','$solarradiation','$UV','$precip_1hr_in','$precip_1hr_metric','$precip_today_string','$precip_today_in','$precip_today_metric'"
	
	echo "		"
	echo "##########################################################"

######################################################################
# ------ GET LUX -----------
# Two ways to get Light Levels
# From a local sensor on the hive, OR
# from a local weather station
######################################################################
	if [ $ENABLE_LUX = "yes" ]; then
		echo "--- GETTING LUX --- "
		lux=$($HOMEDIR/scripts/light/getlux.sh)
	fi
	check lux
	echo "Calculated LUX = $lux"
	#echo "--- LUX DONE --- "
	echo "		"
	echo "##########################################################"


######################################################################
# ------ GET AIR Quality -----------
#  Currently support PurpleAir, but plan on supporting more
######################################################################
	if [[ $ENABLE_AIR = "yes" ]]; then
			echo "--- Getting Air Quality ---"
		
		GETAIR_DATA=$($HOMEDIR/scripts/air/getair.sh)
		
		AIR_DATE=$(echo $GETAIR_DATA |awk -F, '{print $1}')
		AIR_TEMP=$(echo $GETAIR_DATA |awk -F, '{print $2}')
		AIR_HUMIDITY=$(echo $GETAIR_DATA |awk -F, '{print $3}')
		AIR_PM1=$(echo $GETAIR_DATA |awk -F, '{print $4}')
		AIR_PM2_5=$(echo $GETAIR_DATA |awk -F, '{print $5}')
		AIR_PM10=$(echo $GETAIR_DATA |awk -F, '{print $6}')

		check AIR_TEMP
		check AIR_HUMIDITY
		check AIR_PM1
		check AIR_PM2_5
		check AIR_PM10
	
	echo "AIR: $AIR_DATE,$AIR_TEMP, $AIR_HUMIDITY, $AIR_PM1, $AIR_PM2_5, $AIR_PM10"
		else
		echo "--- AIR QUALITY CHECK DISABLED ---"
		AIR_DATE="null"
		AIR_TEMP="null"
		AIR_HUMIDITY="null"
		AIR_PM1="null"
		AIR_PM2_5="null"
		AIR_PM10="null"
	fi
	echo "		"
	echo "##########################################################"
	

######################################################################
# Storing Data in our database
######################################################################
echo "--- Storing in the Database ---"
#set -x
sqlite3 $HOMEDIR/data/hive-data.db "insert into allhivedata (hiveid,date,date_utc,hivetempf,hivetempc,hiveHum,hiveweight,hiverawweight,yardid,sync,beekeeperid,weather_stationID,observationDateTime,weather_tempf,weather_humidity,weather_dewf,weather_tempc,wind_mph,wind_dir,wind_degrees,wind_gust_mph,wind_kph,wind_gust_kph,pressure_mb,pressure_in,pressure_trend,weather_dewc,solarradiation,UV,precip_1hr_in,precip_1hr_metric,precip_today_string,precip_today_in,precip_today_metric,lux,IN_COUNT,OUT_COUNT,air_datetime,air_temp,air_humidity,air_pm1,air_pm2_5,air_pm10) \
values (\"$HIVEID\",\"$DATE\",\"$DATE_UTC\",\"$HIVETEMPF\",\"$HIVETEMPC\",\"$HIVEHUMIDITY\",\"$HIVEWEIGHT\",\"$HIVERAWWEIGHT\",\"$YARDID\",1,\"$BEEKEEPERID\", \"$WEATHER_STATIONID\",\"$OBSERVATIONDATETIME\",\"$A_TEMP\",\"$B_HUMIDITY\",\"$A_DEW\",\"$A_TEMP_C\",\"$A_WIND_MPH\",\"$A_WIND_DIR\",\"$wind_degrees\",\"$wind_gust_mph\",\"$wind_kph\",\"$wind_gust_kph\",\"$pressure_mb\",\"$A_PRES_IN\",\"$A_PRES_TREND\",\"$weather_dewc\",\"$solarradiation\",\"$UV\",\"$precip_1hr_in\",\"$precip_1hr_metric\",\"$precip_today_string\",\"$precip_today_in\",\"$precip_today_metric\",\"$lux\",\"$IN_COUNT\",\"$OUT_COUNT\",\"$AIR_DATE\",\"$AIR_TEMP\",\"$AIR_HUMIDITY\",\"$AIR_PM1\",\"$AIR_PM2_5\",\"$AIR_PM10\");"
	#echo "Success AAD"
#echo "--- Storing in DB DONE ---"
echo "		"

#Get last DB record so we can send to hivecontrol.org in order
record_id=$(sqlite3 $HOMEDIR/data/hive-data.db "select id from allhivedata WHERE date = \"$DATE\";")

######################################################################
# If sharing, create file and send to other people
######################################################################
if [ $SHARE_HIVETOOL = "yes" ]; then
	echo "--- Sharing with Hivetool.org ---"
		# Create XML file, since that is what they like to get
		SAVEFILE=$HOMEDIR/scripts/system/transmit.xml
		echo "<hive_data>" > $SAVEFILE
		echo "        <hive_observation>" >> $SAVEFILE
		echo "                <hive_id>$HIVENAME</hive_id>" >> $SAVEFILE
		echo "                <hive_observation_time>$DATE</hive_observation_time>" >> $SAVEFILE
		echo "                <hive_weight_lbs>$HIVERAWWEIGHT</hive_weight_lbs>" >> $SAVEFILE
		echo "                <hive_temp_c>$HIVETEMPC</hive_temp_c>" >> $SAVEFILE
		echo "                <hive_relative_humidity>$HIVEHUMIDITY</hive_relative_humidity>" >> $SAVEFILE
		echo "                <hive_ambient_temp_c>$A_TEMP_C</hive_ambient_temp_c>" >> $SAVEFILE
		echo "                <hive_ambient_relative_humidity>$B_HUMIDITY</hive_ambient_relative_humidity>" >> $SAVEFILE
		echo "        </hive_observation>" >> $SAVEFILE
		# hivetool likes to get straight wunderground data
		# so we make another call, TODO will be to parse the JSON we already collected, and send them XML
		# Maybe we can convince them to support JSON as well
	        if [ $WEATHER_LEVEL = "hive" ]; then
		#/usr/bin/curl --silent http://api.wunderground.com/api/$KEY/conditions/q/pws:$WXSTATION.xml > $HOMEDIR/scripts/system/wx.xml
		/usr/bin/curl --silent --retry 5 http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=$WXSTATION > $HOMEDIR/scripts/system/wx.xml
		fi
		if [ $WEATHER_LEVEL = "localws" ]; then
		   echo "Local ws Send"
		   rm -rf $HOMEDIR/scripts/system/wx.xml
		   if [ local_wx_type = "WS1400ip" ]; then
		      cp $HOMEDIR/scripts/weather/ws1400/wx.xml $HOMEDIR/scripts/system/wx.xml
		   else
		      cp $HOMEDIR/scripts/weather/ourweather/wx.xml $HOMEDIR/scripts/system/wx.xml			   
		   fi
		fi
		/usr/bin/xmlstarlet sel -t -c "/response/current_observation" $HOMEDIR/scripts/system/wx.xml >> $SAVEFILE
		echo "</hive_data>" >> $SAVEFILE

	#====================
	# Try to send to hivetool
	#====================
	/usr/bin/curl --silent --retry 5 -k -u $HT_USERNAME:$HT_PASSWORD -X POST --data-binary @$SAVEFILE https://hivetool.org/private/log_hive.pl  -H 'Accept: application/xml' -H 'Content-Type: application/xml'
		
fi

if [ -z "$HIVEAPI" ]; then
	echo "--- Unable to share with hivecontrol.org because HIVEAPI is not set"
else
	echo "--- Sharing with hivecontrol.org ---"
	#Call the function to senddata
	hc_senddata
fi
	

# End Sharing

echo "##########################################################"
echo "Script Completed"
echo "##########################################################"
