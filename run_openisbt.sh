#!/bin/bash
#
#
#
OAS_FILES=../openapi-data/oasFilesJson/*
LOG_FILES_DIRECTORY=../openapi-data/analysis/
LOG_FILES=../openapi-data/analysis/*

run_openisbt () {
	for f in $OAS_FILES
	do
  	filename=${f##*/} 
  	echo -e  "Running MatchingTool on file: \t  $filename"
		java -jar openISBTBackend/build/libs/matchingTool-1.0-SNAPSHOT-all.jar -s $f -d resources/patternConfigs/amitExperiment.json -o >$LOG_FILES_DIRECTORY$filename	
	done
}


