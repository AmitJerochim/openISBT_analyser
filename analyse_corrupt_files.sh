#!/bin/bash
OAS_FILES_DIRECTORY="../openapi-data/oasFiles.bak"

OAS_FILES_DIRECTORY=$( echo $OAS_FILES_DIRECTORY | sed 's#/#\\/#g')
less errors.log | grep "Exception occured" | sed 's/Exception occured while processing file:\t //'| sed  "s/^/$OAS_FILES_DIRECTORY\//" >corrupt_files.txt
ALL_SUBRESOURCE_OPERATIONS=0
ALL_TOPLEVEL_OPERATIONS=0
ALL_OPERATIONS=0
	echo -e "Toplevel-Operations;Subresource-Operations;Sum-Toplevel-Operations;Sum-Subresource-Operations;Sum-All-Operations;Current-OAS-File"
cat corrupt_files.txt  | while read line
do 
	TOPLEVEL_OPERATIONS=$( ./helper_functions.sh --count-available-operations -f $line )
	SUBRESOURCE_OPERATIONS=$( node oas_reader.js $line 'true' |  head -n 1 |sed 's/Available Operations:\t//'   )
	ALL_SUBRESOURCE_OPERATIONS=$((ALL_SUBRESOURCE_OPERATIONS+SUBRESOURCE_OPERATIONS))
	ALL_TOPLEVEL_OPERATIONS=$((ALL_TOPLEVEL_OPERATIONS+TOPLEVEL_OPERATIONS))
	ALL_OPERATIONS=$((ALL_OPERATIONS+TOPLEVEL_OPERATIONS+SUBRESOURCE_OPERATIONS))
	echo -e "$TOPLEVEL_OPERATIONS;$SUBRESOURCE_OPERATIONS;$ALL_TOPLEVEL_OPERATIONS;$ALL_SUBRESOURCE_OPERATIONS;$ALL_OPERATIONS;${line##*/}" 
done
rm corrupt_files.txt
