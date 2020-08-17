#!/bin/bash

LOGGINGS=../loggings
OAS_FILES=../../openapi-data/oasFiles/*

read_oas_files () {
	mkdir -p $LOGGINGS/oas_reader_output/toplevel/
	mkdir -p $LOGGINGS/oas_reader_output/subresource/
	for f in $OAS_FILES
	do
		echo $f
		filename=${f##*/}
		node oas_reader.js $f >$LOGGINGS/oas_reader_output/toplevel/$filename	
		node oas_reader.js $f "true" >$LOGGINGS/oas_reader_output/subresource/$filename
	done
}

read_oas_files
