#!/usr/bin/env bash

## Sanjeev Sharma ##
## mmontgomery@mysql.com ##
_currMonth=`date +%B`
logfile=/var/log/sscripts/slaveStatus_$_currMonth.log
errorFile=/var/log/sscripts/errorFile_$_currMonth.log


repeat_alert_interval=15 # minutes
lock_file=/tmp/slave_alert.lck
active=yes

## Check if alert is already sent ##

function check_alert_lock () {

#calling the another function if possible to reset the status of the mysql running 
	. /usr/local/bin/monitoringSH/skipError.sh
       if [ -f $lock_file ] ; then
        current_file=`find $lock_file -cmin -$repeat_alert_interval`
        if [ -n "$current_file" ] ; then
            # echo "Current lock file found"
			# we can perform any action in that like message sending reparing
            return 1
        else
            # echo "Expired lock file found"
			# means thier is not file found their in that particular path
            return 2
        fi
    else
    return 0
    fi
}

## Find the location of the mysql.sock file ##

function check_for_socket () {
        if [ -z $socket ] ; then
                if [ -S /var/lib/mysql/mysql.sock ] ; then
                        socket=/var/lib/mysql/mysql.sock
                elif [ -S /tmp/mysql.sock ] ; then
                        socket=/tmp/mysql.sock
                else
                        ps_socket=`netstat -ln | egrep "mysql(d)?\.sock" | awk '{ print $9 }'`
                        if [ "$ps_socket" ] ; then
                        socket=$ps_socket
                        fi
                fi
        fi
        if [ -S "$socket" ] ; then
                echo "Socket:UP" >> $logfile
        else
                echo "No valid socket file "$socket" found!"  >> $logfile
                echo "mysqld is not running or it is installed in a custom location" >> $logfile
                echo "Please set the $socket variable at the top of this script."  >> $logfile
                exit 1
        fi
}

startPoint="------------------------Started-----------------------------------\n"
	echo "Start on Date:`date`" >> $logfile
	echo -e $startPoint  >> $logfile

check_for_socket
Slave_IO_Running=`mysql  -uscript_mm -p********** -Bse "show slave status\G" | grep Slave_IO_Running | awk '{ print $2 }'`
Slave_SQL_Running=`mysql  -uscript_mm -p********** -Bse "show slave status\G" | grep Slave_SQL_Running | awk '{ print $2 }'`
Last_error=`mysql  -uscript_mm -p********** -Bse "show slave status\G" | grep Last_Error | awk -F \: '{ print $2 $3 }'`

sleep 2
if [ -z $Slave_IO_Running -o -z $Slave_SQL_Running ] ; then
        echo "Replication is not configured or you do not have the required access to MySQL"   >> $logfile
        exit
fi

if [ $Slave_IO_Running == 'Yes' ] && [ $Slave_SQL_Running == 'Yes' ] ; then
    if [ -f $lock_file ] ; then
        rm $lock_file
        echo "Replication slave is running"  >> $logfile
        echo "Removed Alert Lock"  >> $logfile
    fi
    exit 0
elif [ $Slave_SQL_Running == 'No' ] ; then
    if [ $active == 'yes' ] ; then
        check_alert_lock
        if [ $? = 1 ] ; then
            ## Current Lock ##
            echo "Already Created File for Slave_SQL_Running Status"  >> $logfile
        else
            ## Stale/No Lock ##
             touch $lock_file
            echo "SQL thread not running on server `hostname -s`!" >> $logfile
            echo "Last Error: `date`:" $Last_error  >> $errorFile
        fi
    fi
    exit 1
elif [ $Slave_IO_Running == 'No' ] ; then
        if [ $active == 'yes' ] ; then
                check_alert_lock
                if [ $? = 1 ] ; then
                        ## Current Lock ##
            echo "Already Created File for Slave_IO_Running Status"  >> $logfile
                else
                        ## Stale/No Lock ##
                        touch $lock_file
                        echo "LOG IO thread not running on server `hostname -s`!" >> $logfile
                        echo "Last Error: `date`:" $Last_error  >> $errorFile
                fi
    fi
    exit 1
else
        if [ $active == 'yes' ] ; then
                check_alert_lock
                if [ $? = 1 ] ; then
                        ## Current Lock ##
            echo "Default Active Status UP"   >> $logfile
                else
                        ## Stale/No Lock ##
                        touch $lock_file 
            echo "Unexpected Error! `date`:">> $errorFile   
            echo "Check Your permissions!"  >> $errorFile
                fi
        fi
    exit 2
fi
	endPoint="------------------------ENDED-----------------------------------\n"
	echo -e $endPoint  >> $logfile

