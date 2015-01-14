#!/bin/sh
#============================================================================
# Description:  backup individual table definition only (.frm file)

BKP_DATE=`date '+%m-%d-%Y'`
MUSER="dba_backup"
MPASS="wer2234M34"
BACKUP_DIR="/mysqlbackup/PerconXtrabackup/DBBackup/TableDef/"
MYSQLDUMP="/mysql/setup/bin/mysqldump"
MYSQL="/mysql/setup/bin/mysql"
LOGFILE=/mysqlbackup/PerconXtrabackup/scripts/TableStrBackupLog_logs.log
touch ${LOGFILE}
BACKUP_HOME=$BACKUP_DIR$BKP_DATE

if [ ! -d ${BACKUP_HOME} ]; then
   mkdir -p -m 777  ${BACKUP_HOME}
fi

cd $BACKUP_HOME

echo "*****starting backup without Data ( Only Table Structure) at `date '+%m-%d-%Y %H:%M %Z'` " >> $LOGFILE
echo >> $LOGFILE

$MYSQLDUMP  --no-data -u$MUSER   -p$MPASS  mysql > mysql.sql
echo " Mysql table structure backed up successfully.."  >> $LOGFILE
echo >> $LOGFILE
$MYSQLDUMP  --no-data -u$MUSER   -p$MPASS wallet > wallet.sql
echo " Wallet table structure backed up successfully.."  >> $LOGFILE
echo >> $LOGFILE
$MYSQLDUMP  --no-data -u$MUSER   -p$MPASS common_schema > common_schema.sql
echo " common_schema table structure backed up successfully.." >> $LOGFILE
echo  >> $LOGFILE
echo "backup job completed at `date '+%m-%d-%Y %H:%M %Z'` "  >> $LOGFILE
echo  >> $LOGFILE

