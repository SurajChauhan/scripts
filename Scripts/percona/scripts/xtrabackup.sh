#!/bin/sh
# Author: Suraj Chauhan
# Purpose: take full & incremental backup by using Percona Xtra Backup 

TMPFILE="/mysql/PerconXtrabackup/scripts/tmplogs/innobackupex-runner.tmp"
USEROPTIONS="--user=dba_backup --password=*************"
FILTERTABLES="--include=.*[.].*"
BACKDIR=/mysql/PerconXtrabackup/DBBackup
BASEBACKDIR=$BACKDIR/base
INCRBACKDIR=$BACKDIR/incr
#FULLBACKUPLIFE=18000 # 5 hrs # How long to keep incrementing a backup for, minimum 5 hrs
#KEEP=2 # Keep this number of backups, appart form the one currently being incremented

FULLBACKUPLIFE=43200 # Lifetime of the latest full backup in seconds -- 1 Days
KEEP=1 # Number of full backups (and its incrementals) to keep

START=`date +%s`
LOGFILE=/mysql/PerconXtrabackup/scripts/XtraDBbackup_logs.log

touch ${LOGFILE}
echo
echo "**********Wallet-XtraDBbackup******: `date`" >> $LOGFILE
echo
echo "Backup  started on: `date` " >> $LOGFILE
echo "----------------------------------" >> $LOGFILE
echo
 
# Check base dir exists and is writable
if test ! -d $BASEBACKDIR -o ! -w $BASEBACKDIR
then
  error
  echo $BASEBACKDIR 'does not exist or is not writable'; echo >> $LOGFILE
  exit 1
fi
 
# check incr dir exists and is writable
if test ! -d $INCRBACKDIR -o ! -w $INCRBACKDIR
then
  error
  echo $INCRBACKDIR 'does not exist or is not writable'; echo >> $LOGFILE
  exit 1
fi
 
if [ -z "`/mysql/setup/bin/mysqladmin $USEROPTIONS status | grep 'Uptime'`" ]
then
  echo "HALTED: MySQL does not appear to be running."; echo  >> $LOGFILE
  exit 1
fi
 
if ! `echo 'exit' | /mysql/setup/bin/mysql -s $USEROPTIONS`
then
  echo "HALTED: Supplied mysql username or password appears to be incorrect (not copied here for security, see script)"; echo >> $LOGFILE
  exit 1
fi
 
echo "Check completed OK" >> $LOGFILE
 
# Find latest backup directory
LATEST=`find $BASEBACKDIR -mindepth 1 -maxdepth 1 -type d -printf "%P\n" | sort -nr | head -1`
 
AGE=`stat -c %Y $BASEBACKDIR/$LATEST`
 
if [ "$LATEST" -a `expr $AGE + $FULLBACKUPLIFE + 5` -ge $START ]
then
  echo "New incremental backup:`date`" >> $LOGFILE
  # Create an incremental backup
 
  # Check incr sub dir exists
  # try to create if not
  if test ! -d $INCRBACKDIR/$LATEST
  then
    mkdir $INCRBACKDIR/$LATEST
  fi
 
  # Check incr sub dir exists and is writable
  if test ! -d $INCRBACKDIR/$LATEST -o ! -w $INCRBACKDIR/$LATEST
  then
    echo $INCRBASEDIR 'does not exist or is not writable' >> $LOGFILE
    exit 1
  fi
 
  LATESTINCR=`find $INCRBACKDIR/$LATEST -mindepth 1  -maxdepth 1 -type d | sort -nr | head -1`
  if [ ! $LATESTINCR ]
  then
    # This is the first incremental backup
    INCRBASEDIR=$BASEBACKDIR/$LATEST
  else
    # This is a 2+ incremental backup
    INCRBASEDIR=$LATESTINCR
  fi
 
  # Create incremental Backup
  innobackupex --compress $USEROPTIONS $FILTERTABLES --incremental $INCRBACKDIR/$LATEST --incremental-basedir=$INCRBASEDIR > $TMPFILE 2>&1
  echo "Incremental Backup  Completed Successfully on: `date` " >> $LOGFILE
else
  echo 'New full DB backup started on:' `date` >> $LOGFILE
  # Create a new full backup
  innobackupex --compress $USEROPTIONS $FILTERTABLES $BASEBACKDIR > $TMPFILE 2>&1
  echo "Full DB Backup  Completed Successfully on: `date` " >> $LOGFILE
fi
 
if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ]
then
  echo "$INNOBACKUPEX failed:"; echo  >> $LOGFILE
  echo "---------- ERROR OUTPUT from $INNOBACKUPEX ----------" >> $LOGFILE
  cat $TMPFILE
  rm -f $TMPFILE
  exit 1
fi
 
THISBACKUP=`awk -- "/Backup created in directory/ { split( \\\$0, p, \"'\" ) ; print p[2] }" $TMPFILE`
 
echo "Databases backed up successfully to: $THISBACKUP" >> $LOGFILE
echo
 
MINS=$(($FULLBACKUPLIFE * ($KEEP + 1 ) / 60)) 
echo "Cleaning up old backups (older than $MINS minutes) and temporary files" >> $LOGFILE
 
# Rename and Delete tmp file log
cp -r $TMPFILE "$TMPFILE-`date +%Y%m%d%H%S`"
rm -f $TMPFILE
# Delete old bakcups
for DEL in `find $BASEBACKDIR -mindepth 1 -maxdepth 1 -type d -mmin +$MINS -printf "%P\n"`
do
  echo "deleting $DEL" >> $LOGFILE
  rm -rf $BASEBACKDIR/$DEL
  rm -rf $INCRBACKDIR/$DEL
done
 
 
SPENT=$(((`date +%s` - $START) / 60))
echo
echo "took $SPENT minutes" >> $LOGFILE
echo "completed: `date`" >> $LOGFILE
exit 0
