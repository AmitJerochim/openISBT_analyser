#!/bin/bash
#
#
#
OAS_FILES_DIRECTORY=""
OAS_FILES=""
LOG_FILES_DIRECTORY=""
LOG_FILES=""

determine_full_supported_apis () {
	ALL_SUPPORTED_APIS=0
	ALL_APIS=$( ls -l  $LOG_FILES | wc -l) 
	for logFile in $LOG_FILES
	do	
 		filename=${logFile##*/} 
		oasFile=$OAS_FILES_DIRECTORY/$filename.json
		local supported=$(./helper_functions.sh --list-supported-operations --file $logFile | wc -l)
		local available=$(./helper_functions.sh --count-available-operations --file $oasFile)
		
		if [ "$supported" -eq "$available" ];then
			echo -e "$supported of $available operations supported \t $filename"
			ALL_SUPPORTED_APIS=$((ALL_SUPPORTED_APIS+1))
			echo $ALL_SUPPORTED_APIS
		fi
	done
	echo $ALL_SUPPORTED_APIS APIs are fully supported
	echo $ALL_APIS APIs available
	difference=0$( bc -q <<< scale=4\;$ALL_SUPPORTED_APIS/$ALL_APIS )
	echo difference $difference
}

determine_supported_operations () {
	ALL_SUPPORTED_OPERATIONS=0
	ALL_OPERATIONS=0
	
	for f in $LOG_FILES
	do
  	filename=${f##*/} 
		local supported=$( ./helper_functions.sh --list-supported-operations --file $f| wc -l)
		local available=$( ./helper_functions.sh --list-available-operations -f $f )
		ALL_SUPPORTED_OPERATIONS=$((ALL_SUPPORTED_OPERATIONS+supported))
		ALL_OPERATIONS=$((ALL_OPERATIONS+available))
		echo -e "$supported of $available operations are supported in: \t $f"
	done
	echo All supported operations count $ALL_SUPPORTED_OPERATIONS
	echo all available operations count $ALL_OPERATIONS
	difference=0$( bc -q <<< scale=4\;$ALL_SUPPORTED_OPERATIONS/$ALL_OPERATIONS )
	echo difference $difference
}

get_patterns_results () {
	cat $1 | grep "mapping.Mapper"| grep "Mapping\|Pattern\|Operation"
}

determine_candidates () {
	f=../openapi-data/analysis/232_*
	get_patterns_results $f
}

usage () {
echo "Usage:"
echo -e "\t -h, --help \t \t \t \t --> display usage information and exits"
echo -e "\t --log-files-directory\t \t \t \t --> specify a directory containing log files(always required)"
echo -e "\t --oas-files-directory\t \t \t \t --> specify a directory containing oas files(always required)"
echo -e "\t --determine-full-supported-apis\t --> analyse method to run"
echo -e "\t --determine-supported-operations\t --> analyse method to run"
}

while [ "$1" != "" ]; do
	 	case $1 in 
			-h | --help )
				usage
				exit;;
		  --log-files-directory )
				shift
				LOG_FILES_DIRECTORY=$1
				LOG_FILES=$1/*;;
			--oas-files-directory )
				shift
				OAS_FILES_DIRECTORY=$1
				OAS_FILES=$1/*;;
			--determine-supported-operations )
				CMD="determine-supported-operations";;
			--determine-full-supported-apis )
				CMD="determine-full-supported-apis";;
			*)
				echo function does not exists in analyse_api.sh
				exit 1;;
	esac
  shift
done

if [ "$LOG_FILES" == "" ];then
	echo "no log files directory specified. To specify a directory containing log files use --log-files-directory"
	exit 1
fi

if [ "$OAS_FILES" == "" ];then
	echo "no oas files directory specified. To specify a directory containing log files use --oas-files-directory"
	exit 1
fi

if [ "$CMD" == "" ];then
	echo "no function specified. use options to specify a function, e.g., --determine-supported-operations"
	exit 1
fi

case $CMD in
	determine-supported-operations)
		determine_supported_operations;;	
	determine-full-supported-apis)
		determine_full_supported_apis;;
esac

#echo "hello World"
#run_openisbt
#remove_oauth_apis
#remove_iot_api
#remove_pet_store
#remove_corrupt_files 
#determine_full_supported_apis
#determine_supported_operations
#determine_candidates
