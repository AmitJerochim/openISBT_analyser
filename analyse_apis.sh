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
	COUNT_NO_SUBRESOURCES=0
	ALL_APIS=$( ls -l  $LOG_FILES | wc -l) 
	for logFile in $LOG_FILES
	do	
 		filename=${logFile##*/} 
		oasFile=$OAS_FILES_DIRECTORY/$filename.json
		local supported=$(./helper_functions.sh --list-supported-operations --file $logFile | wc -l)
		local available=$(./helper_functions.sh --count-available-operations --file $oasFile)
		local no_subresources=""
		if [ "$supported" -eq "$available" ];then
			local subresource_operations=$( node oas_reader.js $oasFile "true" |  head -n 1 |sed 's/Available Operations:\t//'   )
			if [ "$subresource_operations" -eq 0 ]; then
				no_subresources="*"
				COUNT_NO_SUBRESOURCES=$((COUNT_NO_SUBRESOURCES+1))
			fi
			echo -e "$supported of $available operations supported$no_subresources\t $filename"
			ALL_SUPPORTED_APIS=$((ALL_SUPPORTED_APIS+1))
		fi
	done
	echo $ALL_SUPPORTED_APIS apis are fully supported
	echo $COUNT_NO_SUBRESOURCES of the supported apis do not have sub-resources
	echo $ALL_APIS apis available
	difference_counting_subresources=0$( bc -q <<< scale=4\;$COUNT_NO_SUBRESOURCES/$ALL_APIS)
	difference_ignoring_subresources=0$( bc -q <<< scale=4\;$ALL_SUPPORTED_APIS/$ALL_APIS)
	echo coverage criteria: full-supported-apis ignoring sub-resources $difference_ignoring_subresources
	echo coverage criteria: full-supported-apis considering sub-resources $difference_counting_subresources
}

determine_supported_operations () {
	all_supported_operations=0
	all_operations=0
	
	for f in $log_files
	do
  	filename=${f##*/} 
		local supported=$( ./helper_functions.sh --list-supported-operations --file $f| wc -l)
		local available=$( ./helper_functions.sh --list-available-operations -f $f )
		all_supported_operations=$((all_supported_operations+supported))
		all_operations=$((all_operations+available))
		echo -e "$supported of $available operations are supported in: \t $f"
	done
	echo all supported operations count $all_supported_operations
	echo all available operations count $all_operations
	difference=0$( bc -q <<< scale=4\;$all_supported_operations/$all_operations )
	echo difference $difference
}

get_patterns_results () {
	cat $1 | grep "mapping.mapper"| grep "mapping\|pattern\|operation"
}

determine_candidates () {
	f=../openapi-data/analysis/232_*
	get_patterns_results $f
}

usage () {
echo "usage:"
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
