#!/bin/bash

OAS_FILES=../openapi-data/oasFiles

less loggings/determine_supported_operations.log | grep "^Supports " | sed 's/^Supports //' | sed 's/ of.*operations:\t.*//' >supported_operations.log

less loggings/determine_supported_operations.log | grep "^Supports " | sed 's/^Supports .*of //' | sed 's/ Toplevel.*:\t.*//' >toplevel_operations.log

less loggings/determine_supported_operations.log | grep "^Supports " | sed 's/^Supports .* of.* and //' |sed 's/ Sub-.*//' >subresource_operations.log

less loggings/determine_supported_operations.log | grep "^Supports " | sed 's/.*operations:\t //' >oas_files.log
counter=0

echo -e "API;supported_operations;toplevel_operations;subresource_operations"
cat supported_operations.log | while read supported
do
counter=$((counter+1))
filename=$(head -n $counter oas_files.log | tail -n 1)
toplevel=$(head -n $counter toplevel_operations.log | tail -n 1)
subresource=$(head -n $counter subresource_operations.log | tail -n 1)
if [ "$supported" -le "$toplevel" ];then
	containsKey=$(cat $OAS_FILES/$filename.json |grep "$1")
	if [ "$containsKey" != "" ]; then
		echo -e "$filename;$supported;$toplevel;$subresource"
	fi
fi
done

