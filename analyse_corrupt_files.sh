#!/bin/bash
OAS_FILES_DIRECTORY="../openapi-data/oasFiles.bak"

echo $OAS_FILES_DIRECTORY
OAS_FILES_DIRECTORY=$( echo $OAS_FILES_DIRECTORY | sed 's#/#\\/#g')
echo $OAS_FILES_DIRECTORY
less errors.log | grep "Exception occured" | sed 's/Exception occured while processing file:\t //'| sed  "s/^/$OAS_FILES_DIRECTORY\//" >corrupt_files.txt
ALL_OPERATIONS=0
cat corrupt_files.txt  | while read line
do 
#	echo ${line##*/}
	OPERATIONS=$( ./helper_functions.sh --count-available-operations -f $line )
	ALL_OPERATIONS=$((ALL_OPERATIONS+OPERATIONS))
	echo -e "Operations: \t $OPERATIONS \t allOperations: \t $ALL_OPERATIONS \t Current: \t ${line##*/}" 
done
rm corrupt_files.txt
echo $ALL_OPERATIONS
