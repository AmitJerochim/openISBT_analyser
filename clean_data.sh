#!/bin/bash
#
#
#
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
		else
			local HEAD=$( head -n 1 $f |grep "Will overwrite mapping file")
  		local TAIL=$( tail -n 1 $f |grep "Done.")
			if [[ "$HEAD" == "" || "$TAIL" == "" ]];then
			echo -e  "File has wrong format and will be removed: \t $f"	
			removed=$((removed+1))
			rm $f
		fi
	fi
	done
	echo $removed were removed as they are corrupted
}


remove_petstore_apis () {
	local removed=0
	for f in $LOG_FILES
	do
		./helper_functions.sh --select-resources -f $f >helperFile
		paths=$(cat helperFile | tr -d '\012' )
		if [ "$paths" == "/pet/user/store/inventory/store/order" ];then
			removed=$((removed+1))
			echo -e "File is default petstore and will be removed: \t $f"
			rm $f
		fi
	done
	rm helperFile
	echo "$removed default Petstore Files were removed"
}


remove_oauth_apis () {
	local removed=0
	for f in $LOG_FILES
	do
		./helper_functions.sh --select-resources -f $f >helperFile
		paths=$(cat helperFile | tr -d '\012' )
		if [ "$paths" == "/example/ping" ];then
			removed=$((removed+1))
			echo -e "File is default OAuth API and will be removed: \t $f"
			rm $f
		fi
	done
	rm helperFile
	echo "$removed default OAuth Files were removed"
}



remove_iot_apis () {
	local removed=0
	for f in $LOG_FILES
	do
		./helper_functions.sh --select-resources -f $f >helperFile
		paths=$(cat helperFile | tr -d '\012' )
		if [ "$paths" == "/devices/zones/temperature/lightingSummary/lighting/switches/{deviceId}/lighting/dimmers/{deviceId}/{value}" ];then
			removed=$((removed+1))
			echo -e "File is default IOT API and will be removed: \t $f"
			rm $f
		fi
	done
	rm helperFile
	echo "$removed default IOT Files were removed"
}


usage () {
echo "Usage:"
echo -e "\t -h, --help \t \t --> display usage information and exits"
echo -e "\t --directory\t \t --> specify a directory containing logfiles(always required)"
echo -e "\t --remove-corrupt-files\t --> data cleaning method to run"
echo -e "\t --remove-oauth-apis\t --> data cleaning method to run"
echo -e "\t --remove-petstore-apis\t --> data cleaning method to run"
echo -e "\t --remove-iot-apis\t --> data cleaning method to run"
}


while [ "$1" != "" ]; do
	 	case $1 in 
			-h | --help )
				usage
				exit;;
		  --directory )
				shift
				LOG_FILES_DIRECTORY=$1
				LOG_FILES=$1/*;;
			--remove-corrupt-files )
				CMD="remove-corrupt-files";;
			--remove-oauth-apis )
				CMD="remove-oauth-apis";;
			--remove-petstore-apis )
				CMD="remove-petstore-apis";;
			--remove-iot-apis ) 
				CMD="remove-iot-apis";;
			*)
				echo function does not exists in clear_data.sh
				exit 1;;
	esac
  shift
done

if [ "$LOG_FILES" == "" ];then
	echo "no directory specified. To specify a directory containing log files use --directory"
	exit 1
fi

if [ "$CMD" == "" ];then
	echo "no function specified. use options to specify a function, e.g., --remove-corrupt-files"
	exit 1
fi

case $CMD in
	remove-corrupt-files )
		remove_corrupt_files;;	
	remove-oauth-apis )
			remove_oauth_apis;;
	 remove-petstore-apis)
			remove_petstore_apis;;
	 remove-iot-apis)
			 remove_iot_apis;;
esac