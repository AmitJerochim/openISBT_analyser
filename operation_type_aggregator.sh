#!/bin/bash
LOG_FILES=log_files/*
SUM_CREATE=0
SUM_READ=0
SUM_SCAN=0
SUM_UPDATE=0
SUM_DELETE=0
SUM_AUTHENTICATE=0
SUM_VALIDATE=0
for f in $LOG_FILES
do
creates_in_file=$(cat $f |grep 'mapping.Mapper' | grep 'Operation' | grep ' CREATE ' | wc -l)
reads_in_file=$(cat $f |grep 'mapping.Mapper' | grep 'Operation' | grep ' READ ' | wc -l)
scans_in_file=$(cat $f |grep 'mapping.Mapper' | grep 'Operation' | grep ' SCAN ' | wc -l)
updates_in_file=$(cat $f |grep 'mapping.Mapper' | grep 'Operation' | grep ' UPDATE ' | wc -l)
deletes_in_file=$(cat $f |grep 'mapping.Mapper' | grep 'Operation' | grep ' DELETE ' | wc -l)
authenticates_in_file=$(cat $f |grep 'mapping.Mapper' | grep 'Operation' | grep ' AUTHENTICATE ' | wc -l)
validates_in_file=$(cat $f |grep 'mapping.Mapper' | grep 'Operation' | grep ' VALIDATE ' | wc -l)

SUM_CREATE=$((SUM_CREATE+creates_in_file))
SUM_READ=$((SUM_READ+reads_in_file))
SUM_SCAN=$((SUM_SCAN+scans_in_file))
SUM_UPDATE=$((SUM_UPDATE+updates_in_file))
SUM_DELETE=$((SUM_DELETE+deletes_in_file))
SUM_AUTHENTICATE=$((SUM_AUTHENTICATE+authenticates_in_file))
SUM_VALIDATE=$((SUM_VALIDATE+validates_in_file))
done
echo -e "NUMBER CREATE\t$SUM_CREATE"
echo -e "NUMBER READ\t$SUM_READ"
echo -e "NUMBER SCAN\t$SUM_SCAN"
echo -e "NUMBER UPDATE\t$SUM_UPDATE"
echo -e "NUMBER DELETE\t$SUM_DELETE"
echo -e "NUMBER AUTHENTICATE\t$SUM_AUTHENTICATE"
echo -e "NUMBER VALIDATE\t$SUM_VALIDATE"
