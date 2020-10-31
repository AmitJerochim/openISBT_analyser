#!/bin/bash
OAS_FILES=/home/amit/openapi-data/oasFiles/*
cat /dev/null >falsePositives.log
for f in $OAS_FILES
do
node requestbody_checker.js $f >> falsePositives.log
done
counter=$(grep "####################################" falsePositives.log |wc -l)
echo "" >> falsePositives.log
echo "" >> falsePositives.log
echo -e "False positive Matchings for POST:\t$counter" >> falsePositives.log
