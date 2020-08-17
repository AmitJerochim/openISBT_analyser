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
		local available=$(./helper_functions.sh --count-available-toplevel-operations --file $oasFile)
		local no_subresources=""
		if [ "$supported" -eq "$available" ];then
			local subresource_operations=$(./helper_functions.sh --count-available-subresource-operations --file $oasFile)
			if [ "$subresource_operations" -eq 0 ]; then
				no_subresources="*"
				COUNT_NO_SUBRESOURCES=$((COUNT_NO_SUBRESOURCES+1))
			fi
			echo -e "$supported of $available operations supported$no_subresources\t $filename"
			ALL_SUPPORTED_APIS=$((ALL_SUPPORTED_APIS+1))
		fi
	done
	echo -e "MEASUREMENT SUMMARY:\twe ran the measurement on a set of apis with set size:\t\t\t$ALL_APIS"
	echo -e "MEASUREMENT SUMMARY:\tapis are fully supported ignoring sub-resources:\t\t\t$ALL_SUPPORTED_APIS"
	echo -e "MEASUREMENT SUMMARY:\tNOTICE: * indicates an file that does not define operations on subresources"
	echo -e "MEASUREMENT SUMMARY:\tapis are fully supported considering sub-resources:\t\t\t$COUNT_NO_SUBRESOURCES"
	difference_counting_subresources=0$( bc -q <<< scale=4\;$COUNT_NO_SUBRESOURCES/$ALL_APIS)
	difference_ignoring_subresources=0$( bc -q <<< scale=4\;$ALL_SUPPORTED_APIS/$ALL_APIS)
	echo -e "MEASUREMENT SUMMARY:\tcoverage criteria: full-supported-apis ignoring sub-resources:\t\t$difference_ignoring_subresources"
	echo -e "MEASUREMENT SUMMARY:\tcoverage criteria: full-supported-apis considering sub-resources:\t$difference_counting_subresources"
}

determine_supported_operations () {
	ALL_APIS=$(ls -l $LOG_FILES | wc -l )
	ALL_SUPPORTED_OPERATIONS=0
	ALL_OPERATIONS_WITHOUT_SUBRESOURCES=0
	ALL_OPERATIONS_INCLUDING_SUBRESOURCES=0
	for logFile in $LOG_FILES
	do
  	filename=${logFile##*/} 
		oasFile=$OAS_FILES_DIRECTORY/$filename.json
		local available_subresource_operations=$(./helper_functions.sh --count-available-subresource-operations --file $oasFile)
		local supported=$(./helper_functions.sh --list-supported-operations --file $logFile | wc -l)
		local available_toplevel_operations=$(./helper_functions.sh --count-available-toplevel-operations --file $oasFile)
		ALL_SUPPORTED_OPERATIONS=$((ALL_SUPPORTED_OPERATIONS+supported))
		ALL_OPERATIONS_WITHOUT_SUBRESOURCES=$((ALL_OPERATIONS_WITHOUT_SUBRESOURCES+available_toplevel_operations))
		ALL_OPERATIONS_INCLUDING_SUBRESOURCES=$((ALL_OPERATIONS_INCLUDING_SUBRESOURCES+available_subresource_operations+available_toplevel_operations))
		echo -e "Supports $supported of $available_toplevel_operations Toplevel and $available_subresource_operations Sub-resource operations:\t $filename"
	done
	difference_counting_subresources=0$( bc -q <<< scale=4\;$ALL_SUPPORTED_OPERATIONS/$ALL_OPERATIONS_INCLUDING_SUBRESOURCES)
	difference_ignoring_subresources=0$( bc -q <<< scale=4\;$ALL_SUPPORTED_OPERATIONS/$ALL_OPERATIONS_WITHOUT_SUBRESOURCES)
  echo  -e "MEASUREMENT SUMMARY:\twe ran the measurement on the following amount of files:\t\t$ALL_APIS"
	echo  -e "MEASUREMENT SUMMARY:\tall supported operations:\t\t\t\t\t\t$ALL_SUPPORTED_OPERATIONS"
	echo  -e "MEASUREMENT SUMMARY:\tall available operations ignoring operations on sub-resource:\t\t$ALL_OPERATIONS_WITHOUT_SUBRESOURCES"
	echo  -e "MEASUREMENT SUMMARY:\tall available operations including operations on sub-resource:\t\t$ALL_OPERATIONS_INCLUDING_SUBRESOURCES"
	echo  -e "MEASUREMENT SUMMARY:\tcoverage criteria: supported-operations ignoring sub-resources:\t\t$difference_ignoring_subresources"
	echo  -e "MEASUREMENT SUMMARY:\tcoverage criteria: supported-operations considering sub-resources:\t$difference_counting_subresources"
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
