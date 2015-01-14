#!/bin/bash
# mysql monitor
#
## Include of other file ##
. /usr/local/bin/monitoringSH/secure_check_pid_func.sh
#!/bin/bash
# mysql monitor
#
## Include of other file ##
. /usr/local/bin/monitoringSH/secure_check_pid_func.sh
. /usr/local/bin/alertSH/messageAlertandFunctions.sh
pingFile="/usr/local/bin/monitoringSH/mysql_ping.sh"
sleepfile="/usr/local/bin/monitoringSH/secure_sleep.sh"
restartfile="/usr/local/bin/monitoringSH/mysql_restart.sh"

## Log File Creation ##

_currMonth=`date +%B`
logfile=/var/log/sscripts/mysql_monitor_$_currMonth.log

maxretry=1
if [ `check_ip "mysql_monitor"` != "OK" ]
then
   echo "mysql_monitor is already running" >> $logfile
   exit
fi
#
#echo `date` " start" >> $logfile
#
#rm -f /tmp/mysql_ping.touch
#

checkService1=`echo $cnf_services_to_check |tr '[A-Z]' '[a-z]' |tr ',' ' '`

for checkService in $checkService1
	do 
	statusReturn=`serviceWiseFunction $checkService action`
	echo "Return By the function :>>:="$statusReturn
			if [ "$statusReturn" == "$checkService:notrunning" ]
			then 
				echo "The Requested Service $statusReturn is not Running:"  >> $logfile
					if [ $checkService == "tomcat" ] 
						then
							commandToRunTomcat=$cnf_tomcat_basepath
						for tservice in $commandToRunTomcat
							do
								echo "Starting the Service Using Command :$tservice"  >> $logfile
								echo `$tservice`
							done
					    elif [ $checkService == "mysql" ]
							then
								echo "Mysql is not running"
					fi
			fi
done
check_ip_end "mysql_monitor"
#echo `date` " end" >> $logfile

#. /usr/local/bin/alertSH/messageAlertandFunctions.sh
