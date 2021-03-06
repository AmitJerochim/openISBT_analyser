#!/bin/bash

rm -rf ../../openapi-data/oasFiles
rm -rf ../../openapi-data/oasFiles.bak
rm -rf ../log_files/*
cp -r  ../../openapi-data/oasFiles.bak.bak  ../../openapi-data/oasFiles
rm -f errors.log
rm -rf ../loggings
mkdir ../loggings
cp -r ../oas_reader_output ../loggings/oas_reader_output


#rm ../openapi-data/oasFiles/*
#cp -r  ../openapi-data/oasFiles.bak.bak/000*  ../openapi-data/oasFiles
#cp -r  ../openapi-data/oasFiles.bak.bak/002*  ../openapi-data/oasFiles
#cp -r  ../openapi-data/oasFiles.bak.bak/006*  ../openapi-data/oasFiles
#cp -r  ../openapi-data/oasFiles.bak.bak/201*  ../openapi-data/oasFiles
#cp -r  ../openapi-data/oasFiles.bak.bak/1822*  ../openapi-data/oasFiles
#cp -r  ../openapi-data/oasFiles.bak.bak/amit*  ../openapi-data/oasFiles

#setup the path for a directory containing openAPI 3.0 files in json format.
#	don't use slash at the end of the file: ../oasFiles instead of ../oasFiles/
OAS_FILES_DIRECTORY=../../openapi-data/oasFiles

#setup the path for a directory where your Logging files should be saved
#	don't use slash at the end of the file: ../logFiles instead of ../logFiles/
LOG_FILES_DIRECTORY=../log_files

#setup the path for a pattern configuration file
PATTERN_CONFIG_FILE=../../openISBTModified/resources/patternConfigs/amitExperiment2.json

#setup the path for openISBT matching tool jar
MATCHING_TOOL_JAR=../../openISBTModified/openISBTBackend/build/libs/matchingTool-1.0-SNAPSHOT-all.jar 

#setup the path to log all data
LOGGINGS=../loggings
cp -r $OAS_FILES_DIRECTORY $OAS_FILES_DIRECTORY.bak
OAS_FILES_DIRECTORY_BAK=$OAS_FILES_DIRECTORY.bak

#./read_oas_files.sh


echo "">$LOGGINGS/record_processing.log
./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-short-files >>$LOGGINGS/record_processing.log

./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-insufficient-oas-files >>$LOGGINGS/record_processing.log

./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-not-standard-files >>$LOGGINGS/record_processing.log

./run_openisbt.sh --loggings-directory $LOGGINGS --log-files-directory $LOG_FILES_DIRECTORY --oas-files-directory $OAS_FILES_DIRECTORY --matching-tool-jar $MATCHING_TOOL_JAR --pattern-config-file $PATTERN_CONFIG_FILE >>$LOGGINGS/record_processing.log

./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-sample-apis >>$LOGGINGS/record_processing.log

./clean_data.sh --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --remove-corrupt-files >>$LOGGINGS/record_processing.log


./analyse_apis.sh  --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --determine-full-supported-apis >$LOGGINGS/determine_full_supported_apis.log

./analyse_apis.sh  --oas-files-directory $OAS_FILES_DIRECTORY --log-files-directory $LOG_FILES_DIRECTORY --determine-supported-operations >$LOGGINGS/determine_supported_operations.log

./analyse_corrupt_apis.sh --analyse-files-that-cause-exceptions --log-file $LOGGINGS/errors.log --oas-files-directory $OAS_FILES_DIRECTORY_BAK >$LOGGINGS/evaluate_apis_that_cause_exception.csv

./analyse_corrupt_apis.sh --analyse-files-with-only-subresources --log-file $LOGGINGS/record_processing.log --oas-files-directory $OAS_FILES_DIRECTORY_BAK >$LOGGINGS/evaluate_apis_with_only_subresources.csv

./summarize.sh
