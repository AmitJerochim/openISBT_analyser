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
	echo -e "PROCESSING SUMMARY:\tcaused exceptions:\t$removed"
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
	echo -e "PROCESSING SUMMARY:\tToo short OAS Files\t$removed"
}

remove_insufficient_oas_files () {
	threwError=0
	zeroOperations=0
	for f in $OAS_FILES
	do
		filename=${f##*/}
		./helper_functions.sh --print-toplevel-summary --file $f >helperFile
		error=$( cat helperFile| grep "ERROR occured while processing OAS FILE" )
		if [ "$error" != "" ];then
			echo -e  "oas_reader.js can not process file. Removing file: \t $filename"	
			threwError=$((threwError+1))
			rm $f
		fi
		noOperations=$(./helper_functions.sh --count-available-toplevel-operations -f $f)
		if [ "$noOperations" == "0" ];then
			echo -e  "No operations found. Removing file: \t $filename"	
			zeroOperations=$((zeroOperations+1))
			rm $f
		fi
	rm helperFile
	done
	echo -e "PROCESSING SUMMARY:\tcouldn't be processed:\t$threwError"
	echo -e "PROCESSING SUMMARY:\tno toplevel-operations:\t$zeroOperations"
}

remove_not_standard_files () {
	notStandard=0
	for f in $OAS_FILES
	do
		filename=${f##*/}
#    echo $f
#		cat ../loggings/oas_reader_output/toplevel/$filename>helperFile
		./helper_functions.sh --print-toplevel-summary --file $f >helperFile
#		cat helperFile
		empty=$( cat helperFile |sed '/^Available Operations:.*/d' | sed '/^get.*/d' |sed '/^post.*/d' |sed '/^head.*/d' |sed '/^put.*/d'  |sed '/^patch.*/d'  |sed '/^delete.*/d'  |sed '/^options.*/d'  |sed '/^trace.*/d' )
#		cat helperFile | sed '/^get.*/d' |sed '/^post.*/d' |sed '/^head.*/d' |sed '/^put.*/d'  |sed '/^patch.*/d'  |sed '/^delete.*/d'  |sed '/^options.*/d'  |sed '/^trace.*/d' >helperFile1 
#		cat helperFile1
#		containsBad=$(cat helperFile | grep -i -E " parameter")
	#	cat helperFile | grep -i -E "^parameter"
		if [ "$empty" != "" ];then
			echo -e  "valid but unusual OAS file. Removing file: \t $filename"	
			notStandard=$((notStandard+1))
			rm -rf $f
		fi		
#		if [ "$containsBad" != "" ];then
#			isUnusual=1
#		fi
	done
	echo -e "PROCESSING SUMMARY:\tunusual file structure:\t$notStandard"
}



remove_sample_apis () {
	local removed_simple_apis=0
	local removed_outh_apis=0
	local removed_petstore_apis=0
	local removed_iot_apis=0
	for f in $LOG_FILES
	do
		filename=${f##*/}
		./helper_functions.sh --select-resources -f $f >helperFile
		paths=$(cat helperFile | tr -d '\012' )
		if [ "$paths" == "/inventory" ];then
			removed_simple_apis=$((removed_simple_apis+1))
			echo -e "File is default Simple API and will be removed: \t $f"
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		fi
		if [ "$paths" == "/example/ping" ];then
			removed_outh_apis=$((removed_outh_apis+1))
			echo -e "File is default OAuth API and will be removed: \t $f"
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		fi
		if [ "$paths" == "/devices/zones/temperature/lightingSummary/lighting/switches/{deviceId}/lighting/dimmers/{deviceId}/{value}" ];then
			removed_iot_apis=$((removed_iot_apis+1))
			echo -e "File is default IOT API and will be removed: \t $f"
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		fi
		if [ "$paths" == "/pet/user/store/inventory/store/order" ];then
			removed_petstore_apis=$((removed_petstore_apis+1))
			echo -e "File is default petstore and will be removed: \t $f"
			rm $f
			rm $OAS_FILES_DIRECTORY/$filename.json
		fi
	done
	rm helperFile
	echo -e "PROCESSING SUMMARY:\tremoved simple apis\t$removed_simple_apis"
	echo -e "PROCESSING SUMMARY:\tremoved oauth apis\t$removed_outh_apis"
	echo -e "PROCESSING SUMMARY:\tremoved iot apis\t$removed_iot_apis"
	echo -e "PROCESSING SUMMARY:\tremoved petstore apis\t$removed_petstore_apis"
}


usage () {
echo "Usage:"
echo -e "\t -h, --help \t \t \t\t--> display usage information and exits"
echo -e "\t --log-files-directory\t \t\t--> specify a directory containing log files(always required)"
echo -e "\t --oas-files-directory\t \t\t--> specify a directory containing oas files(always required)"
echo -e "\t --remove-corrupt-files\t \t\t--> removes log files that are corrupt "
echo -e "\t --remove-insufficient-oas-files \t--> removes oas files that can not be processed by oas_reader.js"
echo -e "\t --remove-short-files\t \t\t--> removes oas files that are very short"
echo -e "\t --remove-sample-apis\t \t\t--> removes predefined example api"
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
			--remove-sample-apis )
				CMD="remove-sample-apis";;
			--remove-not-standard-files )
				CMD="remove-not-standard-files";;
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
	remove-sample-apis )
			remove_sample_apis;;
	remove-not-standard-files )
			remove_not_standard_files;;

esac
