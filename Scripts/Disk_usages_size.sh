#!/bin/sh
#============================================================================
# File:          Disk_usages_size.sh
# Description:   This Script will scan mysql data dir & give you database space status.
# Company:       One97
# Usage:         sh Disk_usages_size.sh
#============================================================================

Server_IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
## Set the MySQL Configuration File path default is /etc/my.cnf
FILE_CNF='/etc/my.cnf'


OUT_FILE=/usr/local/bin/monitoringSH/disk-status.txt
>$OUT_FILE

Server_IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
MY_datadir_Value=`grep -v '#' $FILE_CNF | grep 'datadir'  | head -1 `
MY_datadir=`echo $MY_datadir_Value | awk -F"="  '{ print  $NF }'`

declare -a Database_High
Database_High=(`du -hsc $MY_datadir* | grep G`)


Disk_Size=`df -h $MY_datadir`
echo '                      MySQL Data Dir Size'  >> $OUT_FILE
echo  -e "*******************************************************************************"   >> $OUT_FILE
echo $Disk_Size  >> $OUT_FILE
echo  -e "*******************************************************************************"   >> $OUT_FILE


echo  -e "*******************************************************************************"   >> $OUT_FILE
echo  -e "Database Dir Counsuming High Space on Server" >> $OUT_FILE
echo  -e "*******************************************************************************"   >> $OUT_FILE

Database_High_Print=`du -hsc $MY_datadir* | grep G`

echo Database_High_Print |while read line
do
echo "$Database_High_Print"  >> $OUT_FILE
done


echo  -e "-------------------------------------------------------------------------------"   >> $OUT_FILE
for Database_High_Count  in "${Database_High[@]}"
do
if [[ $Database_High_Count == /* ]] ;
then
echo  -e " Tables Consuming High Space In - DB $Database_High_Count"  >> $OUT_FILE
echo  -e "-------------------------------------------------------------------------------"   >> $OUT_FILE
Database_High_Files=`ls -lthaS $Database_High_Count/*  |  head -20`

echo Database_High_Files |while read line
do
echo "$Database_High_Files"  >> $OUT_FILE
done

echo  -e "-------------------------------------------------------------------------------"  >> $OUT_FILE
if [[ $Database_High_Count == *db_arpu* ]];
then
echo "DB Arpu Table Details"  >> $OUT_FILE

cd  $Database_High_Count
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo  -e "Table mmddyyyy present : eventlog "  >> $OUT_FILE
Table_event=`ls  eventlog_*.frm`
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo Table_event |while read line
do
echo "$Table_event"  >> $OUT_FILE
done

echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo  -e "Table mmddyyyy present : applog"  >> $OUT_FILE
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
Table_app=`ls  applog_*.frm`

echo Table_app |while read line
do
echo "$Table_app"  >> $OUT_FILE
done

echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo  -e "Table mmddyyyy present :  sublogs"  >> $OUT_FILE
Table_sub=`ls  sublog_*.frm`
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo Table_sub |while read line
do
echo "$Table_sub"  >> $OUT_FILE
done
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
fi


if [[ $Database_High_Count == *db_ussd ]];
then
echo "DB db_ussd Table Details"  >> $OUT_FILE

cd  $Database_High_Count

echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo  -e "Table mmddyyyy present : eventlog "  >> $OUT_FILE
Table_event=`ls  eventlog_*.frm`
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo Table_event |while read line
do
echo "$Table_event"  >> $OUT_FILE
done

echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo  -e "Table mmddyyyy present : applog"  >> $OUT_FILE
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
Table_app=`ls  applog_*.frm`

echo Table_app |while read line
do
echo "$Table_app"  >> $OUT_FILE
done

echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo  -e "Table mmddyyyy present :  sublogs"  >> $OUT_FILE
Table_sub=`ls  sublog_*.frm`
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
echo Table_sub |while read line
do
echo "$Table_sub"  >> $OUT_FILE
done
echo  -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  >> $OUT_FILE
fi
fi
done

