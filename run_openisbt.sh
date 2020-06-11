#!/bin/bash
#
#
#
OAS_FILES=""
OAS_FILES_DIRECTORY=""
LOG_FILES_DIRECTORY=""
LOG_FILES=""
PATTERN_CONFIG_FILE=""
MATCHING_TOOL_JAR=""

setup_paths () {
	OAS_FILES=$(realpath $OAS_FILES)
	OAS_FILES_DIRECTORY=$(realpath $OAS_FILES_DIRECTORY)
	LOG_FILES_DIRECTORY=$(realpath $LOG_FILES_DIRECTORY)
	LOG_FILES=$(realpath $LOG_FILES)
	PATTERN_CONFIG_FILE=$(realpath $PATTERN_CONFIG_FILE)
	MATCHING_TOOL_JAR=$(realpath $MATCHING_TOOL_JAR)
}

run_openisbt () {
	setup_paths
	for f in $OAS_FILES
	do
		filename=$(echo ${f##*/}| sed -e 's/.json//')
  	echo -e  "Running MatchingTool on file: \t  $filename.json"
		java -jar $MATCHING_TOOL_JAR -s $f -d $PATTERN_CONFIG_FILE -o >$LOG_FILES_DIRECTORY/$filename	
	done
}


usage () {
echo "Usage:"
echo -e "\t -h, --help \t \t \t --> display usage information and exits"
echo -e "\t To run this script all options below are required:"
echo -e "\t --log-files-directory\t \t --> specify a directory containing logfiles"
echo -e "\t --oas-files-directory\t \t --> specify a directory containing oas Files"
echo -e "\t --matching-tool-jar --> specify a jar file to run the openISBT matching tool"
echo -e "\t --pattern-config-file\t \t --> specify a patten configuration file"
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
			--matching-tool-jar )
				shift
				MATCHING_TOOL_JAR=$1;;
			--pattern-config-file )
				shift
				PATTERN_CONFIG_FILE=$1;;
			*)
				echo option does not exist. use -h or --help to check the usage manual.
				exit 1;;
	esac
  shift
done



if [ "$LOG_FILES" == "" ];then
	echo "no log files directory specified. use --log-files-directory to specify a directory. make sure the last character is not a /"
	exit 1
fi

if [ "$OAS_FILES" == "" ];then
	echo "no oas files directory specified. use --oas-files-directory to specify a directory. make sure the last character is not a /"
	exit 1
fi

if [ "$MATCHING_TOOL_JAR" == "" ];then
	echo "no project root directory directory specified. use --openisbt-root-directory to specify a directory."
	exit 1
fi

if [ "$PATTERN_CONFIG_FILE" == "" ];then
	echo "no pattern config file specified. use --pattern-config-file to specify a file."
	exit 1
fi

run_openisbt
