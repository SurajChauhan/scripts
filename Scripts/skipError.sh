#!/bin/sh
## Include of other file ##
. /usr/local/bin/monitoringSH/secure_check_pid_func.sh

_currMonth=`date +%B`
logfile=/var/log/sscripts/slaveStatus_$_currMonth.log
errorFile=/var/log/sscripts/errorFile_$_currMonth.log

        if [ `check_ip "slaveStatusMonitoring"` != "OK" ]
                then
                        echo "[Error Skiping Script is Already Running]" >> $logfile
                exit
        fi
        Slave_SQL_Running=`mysql  -uscript_mm -p********** -Bse "show slave status\G" | grep Slave_SQL_Running | awk '{ print $2 }'`
        Last_Errno=`mysql  -uscript_mm -p********** -Bse "show slave status\G" | grep Last_SQL_Errno | awk '{ print $2 }'`
         while [ $Last_Errno = "1062" ] || [ $Last_Errno = "1032" ] && [ $Slave_SQL_Running = "No"  ]
          do
                lastError=`echo "show slave status\G"|mysql -uscript_mm -p********** |awk '/Last_Error:/'`
                echo `date` $lastError  >> $errorFile
                if [ $counter == 0 ]
                        then
                        skipResult=`echo "stop slave;start slave; "|mysql -uscript_mm -p**********`
                else
                        skipResult=`echo "stop slave;SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;start slave; "|mysql -uscript_mm -p**********`
                fi
                #echo "Skip Counter Execute Result:"$?  >> $logfile
                sleep 1
                Slave_SQL_Running=`mysql  -uscript_mm -p********** -Bse "show slave status\G" | grep Slave_SQL_Running | awk '{ print $2 }'`
                counter=`expr $counter + 1`
                /bin/echo "Counter Runs for:$counter times Current Status of Slave is:"$Slave_SQL_Running  >> $logfile
        done
check_ip_end "slaveStatusMonitoring"

