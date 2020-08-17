#!/bin/bash

LOGGINGS=../loggings
SUMMARY=$LOGGINGS/summary.log
OAS_FILES_BAK=../../openapi-data/oasFiles.bak
echo "#################################" >$SUMMARY
echo "### Summary of the experiment ###" >>$SUMMARY
echo "#################################" >>$SUMMARY
echo -e "\n" >>$SUMMARY

echo "PROCESSING SUMMARY:" >>$SUMMARY
echo -e "PROCESSING SUMMARY:\tProcessed input files:\t$(ls -l $OAS_FILES_BAK/* | wc -l)" >helperFile
cat $LOGGINGS/record_processing.log |grep "PROCESSING SUMMARY" >>helperFile
sed $'s/^/\\t/' helperFile >helperFile2
cat helperFile2 >>$SUMMARY
rm helperFil*

echo "" >>$SUMMARY
echo -e "MEASUREMENT: determine-full-supported-apis" >>$SUMMARY
tail -n 6 $LOGGINGS/determine_full_supported_apis.log >helperFile1
sed $'s/^/\\t/' helperFile1 >helperFile2
head -n 2 helperFile2 >>$SUMMARY
tail -n 3 helperFile2 >>$SUMMARY
rm helperFile*

echo "" >>$SUMMARY
echo -e "MEASUREMENT: determine-supported-operations" >>$SUMMARY
tail -n 6 $LOGGINGS/determine_supported_operations.log >helperFile1
sed $'s/^/\\t/' helperFile1 >helperFile2
#head -n 2 helperFile2 >>$SUMMARY
tail -n 6 helperFile2 >>$SUMMARY
rm helperFile*


echo "" >>$SUMMARY
file=$LOGGINGS/evaluate_apis_that_cause_exception.csv
echo -e "ADDITIONAL MEASUREMENT: evaluate_apis that threw exception" >>$SUMMARY
counter=$(cat $file | wc -l)
counter=$((counter-1))
echo -e "\tADDITIONAL MEASURMENT SUMMARY:\tall Files where exception was thrown:\t\t $counter" >helperFile
echo -e "\tADDITIONAL MEASURMENT SUMMARY:\tsum of operations on toplevel-resources:\t $(tail -n 1 $file| cut -d';' -f3 )" >>helperFile
echo -e "\tADDITIONAL MEASURMENT SUMMARY:\tsum of operations on sub-resources:\t\t $(tail -n 1 $file| cut -d';' -f4 )" >>helperFile
echo -e "\tADDITIONAL MEASURMENT SUMMARY:\tsum of operations on all resources:\t\t $(tail -n 1 $file| cut -d';' -f5 )" >>helperFile
cat helperFile >>$SUMMARY
rm helperFile*

echo "" >>$SUMMARY
file=$LOGGINGS/evaluate_apis_with_only_subresources.csv
echo -e "ADDITIONAL MEASUREMENT: evaluate_apis with only sub-resources" >>$SUMMARY
counter=$(cat $file | wc -l)
counter=$((counter-1))
echo -e "\tADDITIONAL MEASURMENT SUMMARY:\tall Files without toplevel-resources:\t\t $counter" >helperFile
echo -e "\tADDITIONAL MEASURMENT SUMMARY:\tsum of operations on toplevel-resources:\t $(tail -n 1 $file | cut -d';' -f3 )" >>helperFile
echo -e "\tADDITIONAL MEASURMENT SUMMARY:\tsum of operations on sub-resources:\t\t $(tail -n 1 $file | cut -d';' -f4 )" >>helperFile
echo -e "\tADDITIONAL MEASURMENT SUMMARY:\tsum of operations on all resources:\t\t $(tail -n 1 $file | cut -d';' -f5 )" >>helperFile
cat helperFile >>$SUMMARY
rm helperFile*


cat $SUMMARY
