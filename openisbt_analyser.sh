#!/bin/bash

OAS_FILES=../openapi-data/oasFilesJson
LOG_FILES_DIRECTORY=./log_files
PATTERN_CONFIG_FILE=../openISBT/resources/patternConfigs/amitExperiment.json
OPENISBT_ROOT_DIRECTORY=../openISBT

./run_openisbt.sh --log-files-directory $LOG_FILES_DIRECTORY --oas-files-directory $OAS_FILES --openisbt-root-directory  $OPENISBT_ROOT_DIRECTORY --pattern-config-file $PATTERN_CONFIG_FILE

./clean_data.sh --directory $LOG_FILES_DIRECTORY --remove-corrupt-files
./clean_data.sh --directory $LOG_FILES_DIRECTORY --remove-petstore-apis
./clean_data.sh --directory $LOG_FILES_DIRECTORY --remove-iot-apis
./clean_data.sh --directory $LOG_FILES_DIRECTORY --remove-oauth-apis

./analyse_apis.sh  --directory $LOG_FILES_DIRECTORY --determine-full-supported-apis
./analyse_apis.sh  --directory $LOG_FILES_DIRECTORY --determine-supported-operations
