#!/bin/bash
#
#
#
FILE=""
CMD=""

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

extract_supported () {
	local counter=0
	cat $1 | while read line
	do
		local helper=1
		lines=$(cat $1 | wc -l )
		local counter=$((counter+1))
		local chars=$(echo $line | grep "Supported resource mappings:"| wc -m )
		if [ $chars -gt 1 ];then
			helper=$((counter))
			condition=$(cat $1 | tail -n $((lines-helper)) | wc -l )
			if [ $condition -gt 1 ];then
				cat $1 | tail -n $((lines-helper))
			fi
		fi
	done
}


list_available_operations_bak () {
	cat $1 | grep "mapping.Mapper"| grep "Mapping\|Pattern\|Operation" | grep "Pattern" 
}

list_supported_operations_bak () {
	cat $1 | grep "mapping.Mapper"| grep "Mapping\|Pattern\|Operation" | grep "Operation"
}


list_available_operations () {
	cat $1 | grep "mapping.Mapper"| grep "Mapping\|Pattern\|Operation" | grep "Pattern" 
}

list_supported_operations () {
	cat $1 | grep "mapping.Mapper"| grep "Mapping\|Pattern\|Operation" | grep "Pattern\|Operation" >helperFile
	local LINE_COUNTER=0
  local PREV_LINE=""
	cat helperFile|while read line
	do
		IS_FIRST=$(echo $PREV_LINE | grep "Operation" )
		IS_OPERATION=$(echo $line | grep "Operation" )
		#echo $IS_FIRST
#		LINE_COUNTER=$((LINE_COUNTER+1))
		if [[ "$IS_FIRST" == "" ]] && [[ "$IS_OPERATION" != "" ]];then
			echo $line
		fi
		PREV_LINE=$line
	done
	rm helperFile
}

usage () {
	echo "Usage:"
	echo -e "\t -h, --help \t \t \t --> display usage information and exits"
	echo -e "\t -f, --file\t \t \t --> specify a log file(always required)"
	echo -e "\t --count-resources\t \t --> returns the number of resources of an api"
	echo -e "\t --select-resources\t \t -->  lists all resources of an api"
	echo -e "\t --extract-supported\t \t -->  extract the part of the log file full supported resources"
	echo -e "\t --list-available-operations\t lists all available operations-->  "
	echo -e "\t --list-supported-operations\t lists all supported operations-->  "
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
			--extract-supported )
				CMD="extract-supported";;
			--list-available-operations )
				CMD="list-available-operations";;
			--list-supported-operations )
				CMD="list-supported-operations";;	
			*)
				echo function does not exists in helper_functions.sh
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
	extract-supported )
			extract_supported $FILE;;
	list-available-operations )
			list_available_operations $FILE;;
	list-supported-operations )	
			list_supported_operations $FILE;;
esac
