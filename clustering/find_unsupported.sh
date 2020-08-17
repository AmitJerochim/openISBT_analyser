#!/bin/bash

AVAILABLE_OPERATIONS_DIRECTORY=../loggings/oas_reader_output/toplevel
LOG_FILES_DIRECTORY=../log_files
UNSUPPORTED_DIRECTORY=unsupported_files
rm -rf $UNSUPPORTED_DIRECTORY
mkdir -p $UNSUPPORTED_DIRECTORY
#ls -l $AVAILABLE_OPERATIONS_DIRECTORY
for f in $LOG_FILES_DIRECTORY/*
do
	filename=${f##*/}
	lines=$(cat $AVAILABLE_OPERATIONS_DIRECTORY/$filename.json |wc -l)
	operations=$((lines-1))
	tail -n $operations $AVAILABLE_OPERATIONS_DIRECTORY/$filename.json >availableHelper 
	cat $f |grep "mapping.Mapper" |grep "Operation:" | sed 's/ SCAN / get /' | sed 's/ READ / get /' | sed 's/ CREATE / post /' | sed 's/ UPDATE / put /' | sed 's/ DELETE / delete /' | sed 's/ path=/\t/' >supportedHelper
	
#	cat $f |grep "mapping.Mapper" |grep "Operation:" >supportedHelper
	rm -rf $UNSUPPORTED_DIRECTORY/$filename
	cat availableHelper| while read line
	do 
		supported=$(cat supportedHelper | grep "$line")
		if [ "$supported" == "" ];then
			echo $line >>$UNSUPPORTED_DIRECTORY/$filename 
		fi
	done	
done
rm supportedHelper
rm availableHelper
echo "" > unsupported_operations.log
for f in $UNSUPPORTED_DIRECTORY/*
do 
	filename=${f##*/}
	echo $filename>>unsupported_operations.log	
	cat $f | sed 's/^/\t/'>>unsupported_operations.log
#	cat $f >>unsupported_operations.log
done
less unsupported_operations.log
