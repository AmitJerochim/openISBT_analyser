#!/bin/bash
#
#
#
OAS_FILES_DIRECTORY=""
OAS_FILES=""
LOG_FILES_DIRECTORY=""
LOG_FILES=""
CMD=""

remove_corrupt_files () {
	removed=0
	for f in $LOG_FILES
	do
		filename=${f##*/}
		local path=$(find $LOG_FILES_DIRECTORY -empty -name $filename)
		if [ "$path" != "" ];then
			echo -e  "File is empty and will be removed: \t $f"	
			removed=$((removed+1))
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		else
			local HEAD=$( head -n 1 $f |grep "Will overwrite mapping file")
  		local TAIL=$( tail -n 1 $f |grep "Done.")
			if [[ "$HEAD" == "" || "$TAIL" == "" ]];then
			echo -e  "File has wrong format and will be removed: \t $f"	
			removed=$((removed+1))
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		fi
	fi
	done
	echo $removed files were removed because they are corrupted
}

remove_short_files () {
	removed=0
	for f in $OAS_FILES
	do
		local length=$(cat $f | wc -l)
		if [ $length -le 100 ];then
			filename=${f##*/}
			echo -e  "OAS FILE is too short and will be removed: \t $filename"	
			removed=$((removed+1))
			rm $f
		fi
	done
	echo $removed files were removed because the OAS definition was too short
}

remove_insufficient_oas_files () {
	threwError=0
	zeroOperations=0
	for f in $OAS_FILES
	do
		filename=${f##*/}
		node oas_reader.js $f >helperFile
		error=$( cat helperFile| grep "ERROR occured while processing OAS FILE" )
		if [ "$error" != "" ];then
			echo -e  "oas_reader.js can not process file. Removing file: \t $filename"	
			threwError=$((threwError+1))
			rm $f
		fi
		noOperations=$(cat helperFile| head -n 1 |sed 's/Available Operations:\t//' )
		if [ "$noOperations" == "0" ];then
			echo -e  "No operations found. Removing file: \t $filename"	
			zeroOperations=$((zeroOperations+1))
			rm $f
		fi
	rm helperFile
	done
	echo $threwError files were removed because they could not be processed
	echo $zeroOperations files were removed because they have no operations
}


remove_petstore_apis () {
	local removed=0
	for f in $LOG_FILES
	do

		filename=${f##*/}
		./helper_functions.sh --select-resources -f $f >helperFile
		paths=$(cat helperFile | tr -d '\012' )
		if [ "$paths" == "/pet/user/store/inventory/store/order" ];then
			removed=$((removed+1))
			echo -e "File is default petstore and will be removed: \t $f"
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		fi
	done
	rm helperFile
	echo "$removed default Petstore Files were removed"
}


remove_oauth_apis () {
	local removed=0
	for f in $LOG_FILES
	do
		filename=${f##*/}
		./helper_functions.sh --select-resources -f $f >helperFile
		paths=$(cat helperFile | tr -d '\012' )
		if [ "$paths" == "/example/ping" ];then
			removed=$((removed+1))
			echo -e "File is default OAuth API and will be removed: \t $f"
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		fi
	done
	rm helperFile
	echo "$removed default OAuth Files were removed"
}



remove_iot_apis () {
	local removed=0
	for f in $LOG_FILES
	do
		filename=${f##*/}
		./helper_functions.sh --select-resources -f $f >helperFile
		paths=$(cat helperFile | tr -d '\012' )
		if [ "$paths" == "/devices/zones/temperature/lightingSummary/lighting/switches/{deviceId}/lighting/dimmers/{deviceId}/{value}" ];then
			removed=$((removed+1))
			echo -e "File is default IOT API and will be removed: \t $f"
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		fi
	done
	rm helperFile
	echo "$removed default IOT Files were removed"
}


usage () {
echo "Usage:"
echo -e "\t -h, --help \t \t \t\t--> display usage information and exits"
echo -e "\t --log-files-directory\t \t\t--> specify a directory containing log files(always required)"
echo -e "\t --oas-files-directory\t \t\t--> specify a directory containing oas files(always required)"
echo -e "\t --remove-corrupt-files\t \t\t--> removes log files that are corrupt "
echo -e "\t --remove-insufficient-oas-files \t--> removes oas files that can not be processed by oas_reader.js"
echo -e "\t --remove-short-files\t \t\t--> removes oas files that are very short"
echo -e "\t --remove-oauth-apis\t \t\t--> removes predefined example api"
echo -e "\t --remove-petstore-apis\t \t\t--> removes predefined example api"
echo -e "\t --remove-iot-apis\t \t\t--> removes predefined example api"
}



while [ "$1" != "" ]; do
	 	case $1 in 
			-h | --help )
				usage
				exit;;
		  --oas-files-directory )
				shift
				OAS_FILES_DIRECTORY=$1
				OAS_FILES=$1/*;;
		  --log-files-directory )
				shift
				LOG_FILES_DIRECTORY=$1
				LOG_FILES=$1/*;;
			--remove-corrupt-files )
				CMD="remove-corrupt-files";;
			--remove-insufficient-oas-files )
				CMD="remove-insufficient-oas-files";;
			--remove-short-files )
				CMD="remove-short-files";;
			--remove-oauth-apis )
				CMD="remove-oauth-apis";;
			--remove-petstore-apis )
				CMD="remove-petstore-apis";;
			--remove-iot-apis ) 
				CMD="remove-iot-apis";;
			*)
				echo -e "invalid option:\t $1\t  Use --help to get usage manual"
				exit 1;;
	esac
  shift
done

if [ "$OAS_FILES" == "" ];then
	echo "no oas files directory specified. To specify a directory containing log files use --oas-files-directory"
	exit 1
fi

if [ "$LOG_FILES" == "" ];then
	echo "no log files directory specified. To specify a directory containing log files use --log-files-directory"
	exit 1
fi

if [ "$CMD" == "" ];then
	echo "no function specified. use options to specify a function, e.g., --remove-corrupt-files"
	exit 1
fi



case $CMD in
	remove-corrupt-files )
		remove_corrupt_files;;	
	remove-insufficient-oas-files )
		remove_insufficient_oas_files;;	
	remove-short-files )
		remove_short_files;;	
	remove-oauth-apis )
			remove_oauth_apis;;
	 remove-petstore-apis )
			remove_petstore_apis;;
	 remove-iot-apis )
			 remove_iot_apis;;
esac
