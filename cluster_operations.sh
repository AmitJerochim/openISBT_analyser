#!/bin/bash

UNSUPPORTED_DIRECTORY=unsupported_files
OAS_FILES_DIRECTORY=../openapi-data/oasFiles

for f in $UNSUPPORTED_DIRECTORY/*
do
rm -rf operationsHelper
filename=${f##*/}
node json_pattern_finder.js $OAS_FILES_DIRECTORY/$filename.json $f $1 >operationsHelper
operations=$(cat operationsHelper)
if [ "$operations" != "" ]; then
	echo $filename
	cat operationsHelper
  echo ""
fi
done

