#!/bin/bash

#cat loggings/record*.log |grep "File has wrong format and will be removed:" | sed 's/File has wrong format and will be removed://'|sed 's/ //' | sed 's/\t//' | sed 's/ //' >helperFile 

less loggings/determine_supported_operations.log | grep "^Supports " | sed 's/^Supports //' | sed 's/ of.*operations:\t.*//' >supported_operations.log

less loggings/determine_supported_operations.log | grep "^Supports " | sed 's/^Supports .*of //' | sed 's/ Toplevel.*:\t.*//' >toplevel_operations.log

less loggings/determine_supported_operations.log | grep "^Supports " | sed 's/^Supports .* of.* and //' |sed 's/ Sub-.*//' >subresource_operations.log

less loggings/determine_supported_operations.log | grep "^Supports " | sed 's/.*operations:\t//' >oas_files.log
counter=0

echo -e "API;supported_operations;toplevel_operations;full_supported;subresource_operations"
cat supported_operations.log | while read supported
do
counter=$((counter+1))

filename=$(head -n $counter oas_files.log | tail -n 1)
full_supported="false"
toplevel=$(head -n $counter toplevel_operations.log | tail -n 1)
subresource=$(head -n $counter subresource_operations.log | tail -n 1)
if [ "$supported" -eq "$toplevel" ];then
	full_supported="true";
fi
echo -e "$filename;$supported;$toplevel;$full_supported;$subresource"
done

