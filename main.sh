#!/bin/bash
#
#setup the path for a directory containing openAPI 3.0 files in json format.
#	don't use slash at the end of the file: ../oasFiles instead of ../oasFiles/
#
OAS_FILES_DIRECTORY=../openapi-data/oasFiles

#
#setup the path for a directory where your Logging files should be saved
#	don't use slash at the end of the file: ../logFiles instead of ../logFiles/
#
LOG_FILES_DIRECTORY=./log_files

#
#setup the path for a pattern configuration file
#
PATTERN_CONFIG_FILE=../openISBT/resources/patternConfigs/amitExperiment.json

#
#setup the path for openISBT matching tool jar
#
MATCHING_TOOL_JAR=../openISBT/openISBTBackend/build/libs/matchingTool-1.0-SNAPSHOT-all.jar 


#./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-short-files
#./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-insufficient-oas-files


#./run_openisbt.sh --log-files-directory $LOG_FILES_DIRECTORY --oas-files-directory $OAS_FILES_DIRECTORY --matching-tool-jar $MATCHING_TOOL_JAR --pattern-config-file $PATTERN_CONFIG_FILE


#./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-corrupt-files
#./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-petstore-apis
#./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-iot-apis
#./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-oauth-apis

./analyse_apis.sh  --directory $LOG_FILES_DIRECTORY --determine-full-supported-apis
#./analyse_apis.sh  --directory $LOG_FILES_DIRECTORY --determine-supported-operations
