#!/bin/sh
# Author: Suraj Chauhan
# Defragment the query cache to better utilize its memory


LOGFILE=/backup/scripts/FlushQueryCache.log
touch ${LOGFILE}

echo "********** Flush Query Cache started at : ******: `date`" >> $LOGFILE
/mysql/setup/bin/mysql -uUsrFlushQC -p********** -e "Flush Query Cache;"
echo "**********Flush Query Cache finished at : ******: `date`" >> $LOGFILE
echo " " >> $LOGFILE
