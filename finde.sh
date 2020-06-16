#!/bin/bash

cat loggings/record*.log |grep "File has wrong format and will be removed:" | sed 's/File has wrong format and will be removed://'|sed 's/ //' | sed 's/\t//' | sed 's/ //' >helperFile 

cat helperFile | while read line
do
	filename=${line##*/}
	inside=$(cat loggings/errors.log | grep "$filename")
	if [ "$inside" == "" ];then
	echo $line	
	fi
done

cat loggings/record*.log |grep "File has wrong format and will be removed:" >helperFile 

cat helperFile |while read line
do
	multiple=$(cat helperFile |grep "$line" | wc -l )
 	if [ "$multiple" -gt 1 ]; then
		echo $line
	fi
done
