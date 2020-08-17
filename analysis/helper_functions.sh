#!/bin/bash
#
#
#
FILE=""
CMD=""
LOGGINGS=../loggings
list_available_operations () {
	node oas_reader.js $1 | grep "get\|post\|fetch\|put\|delete\|head\|options\|connect\|trace" 
}

count_available_toplevel_operations () {
	f=$1
	filename=${f##*/}
	path=$LOGGINGS/oas_reader_output/toplevel/$filename
	cat $path | head -n 1 |sed 's/Available Operations:\t//'   
}

count_available_subresource_operations () {
	f=$1
	filename=${f##*/}
	path=$LOGGINGS/oas_reader_output/subresource/$filename
	cat $path | head -n 1 |sed 's/Available Operations:\t//'   
}

print_toplevel_summary () {
	f=$1
	filename=${f##*/}
	path=$LOGGINGS/oas_reader_output/toplevel/$filename
	cat $path
}

print_subresource_summary () {
	f=$1
	filename=${f##*/}
	path=$LOGGINGS/oas_reader_output/subresource/$filename
	cat $path
}

list_supported_operations () {
	cat $1 | grep "mapping.Mapper"| grep "Mapping\|Pattern\|Operation" | grep "Operation" 
}


count_resources () {
	local counter=0
	cat $1 | while read line
	do
		counter=$((counter+1))
		local chars=$(echo $line | grep "\-\-\-\-\-\-\-\-\-\-\-\-"| wc -m )
		if [ $chars -gt 1 ];then
			counter=$((counter -3))
			echo $counter;
		fi
	done
}

select_resources () {
	local counter=$(count_resources $1)
	cat $1 | head -n $((counter+2)) | tail -n $counter| while read line
	do 
	echo $line | cut -c 57- 
	done
}

#extract_supported () {
#	local counter=0
#	cat $1 | while read line
#	do
#		local helper=1
#		lines=$(cat $1 | wc -l )
#		local counter=$((counter+1))
#		local chars=$(echo $line | grep "Supported resource mappings:"| wc -m )
#		if [ $chars -gt 1 ];then
#			helper=$((counter))
#			condition=$(cat $1 | tail -n $((lines-helper)) | wc -l )
#			if [ $condition -gt 1 ];then
#				cat $1 | tail -n $((lines-helper))
#			fi
#		fi
#	done
#}


usage () {
	echo "Usage:"
	echo -e "\t -h, --help \t \t \t --> display usage information and exits"
	echo -e "\t -f, --file\t \t \t --> specify a log file or oas file(always required)"
	echo -e "\t --count-resources\t \t --> returns the number of resources of an api (requires log file)"
	echo -e "\t --select-resources\t \t -->  lists all resources of an api (requires log file)"
	echo -e "\t --extract-supported\t \t -->  extract the part of the log file full supported resources (requires log file)"
	echo -e "\t --list-available-operations\t --> lists all available operations (requires oas file) "
	echo -e "\t --count-available-operations\t --> counts all available operations (requires oas file) "
	echo -e "\t --list-supported-operations\t --> lists all supported operations (requires log file) "
}

while [ "$1" != "" ]; do
	 	case $1 in 
			-h | --help)
				usage
				exit;;
			-f | --file )
				shift
				FILE=$1;;
			--count-resources ) 
				CMD="count-resources";;
			--select-resources )
				CMD="select-resources";;
#			--extract-supported )
#				CMD="extract-supported";;
			--list-available-operations )
				CMD="list-available-operations";;
			--list-supported-operations )
				CMD="list-supported-operations";;	
			--count-available-subresource-operations )
				CMD="count-available-subresource-operations";;
			--count-available-toplevel-operations )
				CMD="count-available-toplevel-operations";;
			--print-toplevel-summary )
				CMD="print-toplevel-summary";;
			--print-subresource-summary )
				CMD="print-subresource-summary";;
			*)
				echo option does not exist. you may use --helpt for further information
				exit 1;;
	esac
  shift
done

if [ "$FILE" == "" ];then
	echo "no file specified. please specify a file using -f or --file"
	exit 1
fi

if [ "$CMD" == "" ];then
	echo "no function specified. use options to specify a function, e.g., --count-resources"
	exit 1
fi

case $CMD in
	count-resources )
			count_resources $FILE;;	
	select-resources )
			select_resources $FILE;;
#	extract-supported )
#			extract_supported $FILE;;
	list-available-operations )
			list_available_operations $FILE;;
	list-supported-operations )	
			list_supported_operations $FILE;;
	count-available-toplevel-operations )
			count_available_toplevel_operations $FILE;;
	count-available-subresource-operations )
			count_available_subresource_operations $FILE;;
	print-subresource-summary )
			print_subresource_summary $FILE;;
	print-toplevel-summary )
			print_toplevel_summary $FILE;;
esac
