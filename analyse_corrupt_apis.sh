#!/bin/bash
OAS_FILES_DIRECTORY=""
LOG_FILE=""
CMD=""

list_files_that_cause_exceptions () {
OAS_FILES_DIRECTORY=$( echo $OAS_FILES_DIRECTORY | sed 's#/#\\/#g')
less $1 | grep "Exception occured" | sed 's/Exception occured while processing file:\t //'| sed  "s/^/$OAS_FILES_DIRECTORY\//"
}

list_files_with_only_subresources () {
	OAS_FILES_DIRECTORY=$( echo $OAS_FILES_DIRECTORY | sed 's#/#\\/#g')
	cat $1 | grep "No operations found" | sed 's/No operations found. Removing file: \t //' | sed "s/^/$OAS_FILES_DIRECTORY\//" 
}

print_csv () {
	ALL_SUBRESOURCE_OPERATIONS=0
	ALL_TOPLEVEL_OPERATIONS=0
	ALL_OPERATIONS=0
	echo -e "Toplevel-Operations;Subresource-Operations;Sum-Toplevel-Operations;Sum-Subresource-Operations;Sum-All-Operations;Current-OAS-File"
	cat $1 | while read line
	do 
		TOPLEVEL_OPERATIONS=$( ./helper_functions.sh --count-available-operations -f $line )
		SUBRESOURCE_OPERATIONS=$( node oas_reader.js $line 'true' |  head -n 1 |sed 's/Available Operations:\t//'   )
		ALL_SUBRESOURCE_OPERATIONS=$((ALL_SUBRESOURCE_OPERATIONS+SUBRESOURCE_OPERATIONS))
		ALL_TOPLEVEL_OPERATIONS=$((ALL_TOPLEVEL_OPERATIONS+TOPLEVEL_OPERATIONS))
		ALL_OPERATIONS=$((ALL_OPERATIONS+TOPLEVEL_OPERATIONS+SUBRESOURCE_OPERATIONS))
		echo -e "$TOPLEVEL_OPERATIONS;$SUBRESOURCE_OPERATIONS;$ALL_TOPLEVEL_OPERATIONS;$ALL_SUBRESOURCE_OPERATIONS;$ALL_OPERATIONS;${line##*/}" 
	done
}

analyse_files_that_cause_exceptions () {
	list_files_that_cause_exceptions $LOG_FILE >corrupt_files.txt
	print_csv corrupt_files.txt
	rm corrupt_files.txt
}


analyse_files_with_only_subresources () {
	list_files_with_only_subresources $LOG_FILE >corrupt_files.txt
	print_csv corrupt_files.txt
	rm corrupt_files.txt
}

usage () {
	echo "Usage:" 
	echo -e "\t -h, --help \t\t --> return usage"
	echo -e "\t --oas-files-directory \t--> path to containing all corrupted files"
	echo -e "\t --log-file \t--> path to a error.logs file produced by run_openisbt.sh"
}

while [ "$1" != "" ]; do
	 	case $1 in 
			-h | --help )
				usage
				exit;;
		  --oas-files-directory )
				shift
				OAS_FILES_DIRECTORY=$1;;
		  --log-file )
				shift
				LOG_FILE=$1;;
			--analyse-files-that-cause-exceptions )
				CMD="--analyse-files-that-cause-exceptions";;
			 --analyse-files-with-only-subresources )
				CMD="--analyse-files-with-only-subresources";;
			*)
				echo -e "invalid option:\t $1\t  Use --help to get usage manual"
				exit 1;;
	esac
  shift
done


if [ "$OAS_FILES_DIRECTORY" == "" ];then
	echo "no oas files directory specified. Use --oas-files-directory"
	exit 1
fi

if [ "$LOG_FILE" == "" ];then
	echo "log file is not specified. Use --log-file"
	exit 1
fi

case $CMD in
	--analyse-files-that-cause-exceptions )
		analyse_files_that_cause_exceptions;;	
	--analyse-files-with-only-subresources )
		analyse_files_with_only_subresources;;	
esac
