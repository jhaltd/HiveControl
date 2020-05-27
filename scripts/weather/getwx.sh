#!/bin/bash
# version 2018-01-18-1
#         reads the LUX sensors as one script
# version 2020-05-23-1
#         reads local weather station type Ourweather
# 

# Get some variables from our central file
source /home/HiveControl/scripts/hiveconfig.inc
source /home/HiveControl/scripts/data/logger.inc
source /home/HiveControl/scripts/data/check.inc

PATH=/usr/local/sbin:/usr/local/bin:/bin:/sbin:/usr/sbin:/usr/bin:/home/HiveControl/scripts/weather:/home/HiveControl/scripts/system


DATE=$(TZ=":$TIMEZONE" date '+%F %T')
WEATHER_STATIONID="$WXSTATION"
JSON_PATH="/home/HiveControl/scripts/weather/JSON.sh"

	A_TEMP="null"
	A_TEMP_C="null"
	B_HUMIDITY="null"
	pressure_mb="null"
	A_PRES_IN="null"
	UV="null"
	solarradiation="null"
	precip_1hr_in="null"
	precip_1hr_metric="null"
	solarradiation="null"
	wind_degrees="null"
	wind_gust_kph="null"
	wind_gust_mph="null"
	wind_kph="null"
	wind_mph="null"
	A_WIND_MPH="null"

if [ $WEATHER_LEVEL = "hive" ]; then

		GETNOW=$($HOMEDIR/scripts/weather/wxunderground/getwxxml.sh)

		if [[ -z "$GETNOW" ]] || [[ "$GETNOW" == "" ]];  then
			#echo "Getnow was empty"
			wind_degrees="null"
			wind_gust_kph="null"
			wind_gust_mph="null"
			wind_kph="null"
			wind_mph="null"
			A_WIND_MPH="null"
		else 
			#Get the data fields that differ from the main set
			A_TEMP=`/bin/echo $GETNOW | $JSON_PATH -b |grep temp_f |awk -F"\"" '{print $6}'`
			A_TEMP_C=`/bin/echo $GETNOW | $JSON_PATH -b |grep temp_c |awk -F"\"" '{print $6}'`
			A_WIND_MPH=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_mph |awk -F"\"" '{print $6}'`
			OBSERVATIONDATETIME=`/bin/echo $GETNOW | $JSON_PATH -b |grep observation_time |awk -F"\"" '{print $6}'`
			wind_degrees=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_degrees |awk -F"\"" '{print $6}'`
			wind_gust_mph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_gust_mph |awk -F"\"" '{print $6}'`
			wind_kph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_kph |awk -F"\"" '{print $6}'`
			wind_gust_kph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_gust_kph |awk -F"\"" '{print $6}'`
			weather_dewc=`/bin/echo $GETNOW | $JSON_PATH -b |grep dewpoint_c |awk -F"\"" '{print $6}'`
		fi

elif [ $WEATHER_LEVEL = "localws" ]; then
     if [ local_wx_type = "WS1400ip" ]; then
		# Logic to support WS1400ip Weather station
		GETNOW=`$HOMEDIR/scripts/weather/ws1400/getWS1400.sh`
	 else
	    # Logic to support Switchdoc's Ourweather Ambient weather station -> local_wx_type = "ourweather"
		GETNOW=`$HOMEDIR/scripts/weather/ourweather/getOurweather.sh`
	 fi
	 
	 if [[ -z "$GETNOW" ]] || [[ "$GETNOW" == "" ]];  then
		#echo "Getnow was empty"
		wind_degrees="null"
		wind_gust_kph="null"
		wind_gust_mph="null"
		wind_kph="null"
		wind_mph="null"
		A_WIND_MPH="null"
	else 
		#Get the data fields that differ from the main set

		A_TEMP=`/bin/echo $GETNOW | $JSON_PATH -b |grep temp_f |awk '{print $2}'`
		A_TEMP_C=`/bin/echo $GETNOW | $JSON_PATH -b |grep temp_c |awk '{print $2}'`
		A_WIND_MPH=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_mph |awk -F"\"" '{print $6}'`
		OBSERVATIONDATETIME=`/bin/echo $GETNOW | $JSON_PATH -b |grep observation_time |awk -F"\"" '{print $6}'`
		wind_degrees=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_degrees |awk -F"\"" '{print $6}'`
		wind_gust_mph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_gust_mph |awk -F"\"" '{print $6}'`
		wind_kph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_kph |awk -F"\"" '{print $6}'`
		wind_gust_kph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_gust_kph |awk -F"\"" '{print $6}'`
		weather_dewc=`/bin/echo $GETNOW | $JSON_PATH -b |grep dewpoint_c |awk -F"\"" '{print $6}'`
	fi
	
elif [ $WEATHER_LEVEL = "localsensors" ]; then
		#echo "	- Getting from LocalSensors"
		GETNOW=`$HOMEDIR/scripts/weather/localsensors/localsensors.sh`
		
		WEATHER_STATIONID="LOCALSENSOR"
		#Get the data fields that differ from the main set
		A_TEMP=`/bin/echo $GETNOW | $JSON_PATH -b |grep temp_f |awk '{print $2}'`
		A_TEMP_C=`/bin/echo $GETNOW | $JSON_PATH -b |grep temp_c |awk '{print $2}'`
		A_WIND_MPH=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_mph |awk -F"\"" '{print $6}'`
		OBSERVATIONDATETIME=`/bin/echo $GETNOW | $JSON_PATH -b |grep observation_time |awk -F"\"" '{print $6}'`
		wind_degrees=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_degrees |awk -F"\"" '{print $6}'`
		wind_gust_mph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_gust_mph |awk -F"\"" '{print $6}'`
		wind_kph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_kph |awk -F"\"" '{print $6}'`
		wind_gust_kph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_gust_kph |awk -F"\"" '{print $6}'`
		weather_dewc=`/bin/echo $GETNOW | $JSON_PATH -b |grep dewpoint_c |awk -F"\"" '{print $6}'`

elif [ $WEATHER_LEVEL = "ambientwx" ]; then
		#Getting information from a local weather station that is providing it's data to ambientweather.net
		GETNOW=$($HOMEDIR/scripts/weather/ambient/getAmbientAPI.sh)

		if [[ -z "$GETNOW" ]] || [[ "$GETNOW" == "" ]];  then
			#echo "Getnow was empty"
			wind_degrees="null"
			wind_gust_kph="null"
			wind_gust_mph="null"
			wind_kph="null"
			wind_mph="null"
			A_WIND_MPH="null"
		else 
			#Get the data fields that differ from the main set
			A_TEMP=`/bin/echo $GETNOW | $JSON_PATH -b |grep temp_f |awk -F"\"" '{print $6}'`
			A_TEMP_C=`/bin/echo $GETNOW | $JSON_PATH -b |grep temp_c |awk -F"\"" '{print $6}'`
			A_WIND_MPH=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_mph |awk -F"\"" '{print $6}'`
			OBSERVATIONDATETIME=`/bin/echo $GETNOW | $JSON_PATH -b |grep observation_time |awk -F"\"" '{print $6}'`
			wind_degrees=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_degrees |awk -F"\"" '{print $6}'`
			wind_gust_mph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_gust_mph |awk -F"\"" '{print $6}'`
			wind_kph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_kph |awk -F"\"" '{print $6}'`
			wind_gust_kph=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_gust_kph |awk -F"\"" '{print $6}'`
			weather_dewc=`/bin/echo $GETNOW | $JSON_PATH -b |grep dewpoint_c |awk -F"\"" '{print $6}'`
		fi
fi
	#Parse the weather 
	# Data Parsers for all weather sources

	if [[ -z "$GETNOW" ]] || [[ "$GETNOW" == "" ]];  then
			#echo "Getnow was empty for second time"
			loglocal "$DATE" WXAmbient  ERROR "Error connecting to Weather Source, skipping collection..."		
		else 
			
			A_TIME=`/bin/echo $GETNOW | $JSON_PATH -b |grep observation_epoch |awk -F"\"" '{print $6}'`
			A_HUMIDITY=`/bin/echo $GETNOW | $JSON_PATH -b |grep relative_humidity |awk -F"\"" '{print $6}'`
			B_HUMIDITY=`/bin/echo $A_HUMIDITY | grep -o "\-*[0-9]*\.*[0-9]*"`
			A_WIND_DIR=`/bin/echo $GETNOW | $JSON_PATH -b |grep wind_dir |awk -F"\"" '{print $6}'`
			A_PRES_IN=`/bin/echo $GETNOW | $JSON_PATH -b |grep pressure_in |awk -F"\"" '{print $6}'`
			A_PRES_TREND=`/bin/echo $GETNOW | $JSON_PATH -b |grep pressure_trend |awk -F"\"" '{print $6}'`
			A_DEW=`/bin/echo $GETNOW | $JSON_PATH -b |grep dewpoint_f |awk '{print $2}'`
			#WEATHER_STATIONID=`/bin/echo $GETNOW | $JSON_PATH -b |grep station_id |awk '{print $2}'`
			pressure_mb=`/bin/echo $GETNOW | $JSON_PATH -b |grep pressure_mb |awk -F"\"" '{print $6}'`
			UV=`/bin/echo $GETNOW | $JSON_PATH -b |grep UV |awk -F"\"" '{print $6}'`
			precip_1hr_in=`/bin/echo $GETNOW | $JSON_PATH -b |grep precip_1hr_in |awk -F"\"" '{print $6}'`
			precip_1hr_metric=`/bin/echo $GETNOW | $JSON_PATH -b |grep precip_1hr_metric |awk -F"\"" '{print $6}'`
			precip_today_string=`/bin/echo $GETNOW | $JSON_PATH -b |grep precip_today_string |awk -F"\"" '{print $6}'`
			precip_today_in=`/bin/echo $GETNOW | $JSON_PATH -b |grep precip_today_in |awk -F"\"" '{print $6}'`
			precip_today_metric=`/bin/echo $GETNOW | $JSON_PATH -b |grep precip_today_metric |awk -F"\"" '{print $6}'`
			solarradiation=`/bin/echo $GETNOW | $JSON_PATH -b |grep solarradiation |awk -F"\"" '{print $6}'`
			lux="0"
		fi
	
	#Check for non zero values
	check_allow_neg A_TEMP
	check B_HUMIDITY
	check_allow_neg A_DEW
	check_allow_neg A_TEMP_C
	check A_WIND_MPH
	check A_WIND_DIR
	check wind_degrees
	check wind_gust_mph
	check wind_kph
	check wind_gust_kph
	check pressure_mb
	check A_PRES_IN
	check A_PRES_TREND
	check_allow_neg weather_dewc
	check solarradiation
	check UV
	check precip_1hr_in
	check precip_1hr_metric
	check precip_today_string
	check precip_today_in
	check precip_today_metric

	#echo "weather_stationID,observationDateTime,weather_tempf,weather_humidity,weather_dewf,weather_tempc,wind_mph,wind_dir,wind_degrees,wind_gust_mph,wind_kph,wind_gust_kph,pressure_mb,pressure_in,pressure_trend,weather_dewc,solarradiation,UV,precip_1hr_in,precip_1hr_metric,precip_today_string,precip_today_in,precip_today_metric"
	echo "$WEATHER_STATIONID,$OBSERVATIONDATETIME,$A_TEMP,$B_HUMIDITY,$A_DEW,$A_TEMP_C,$A_WIND_MPH,$A_WIND_DIR,$wind_degrees,$wind_gust_mph,$wind_kph,$wind_gust_kph,$pressure_mb,$A_PRES_IN,$A_PRES_TREND,$weather_dewc,$solarradiation,$UV,$precip_1hr_in,$precip_1hr_metric,$precip_today_string,$precip_today_in,$precip_today_metric"
	#echo "--- Getting Ambient Weather Done ---"

