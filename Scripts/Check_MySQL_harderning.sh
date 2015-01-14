#!/bin/sh
#============================================================================
# File:           Check_MySQL_harderning.sh
# Description:   This Script will few system command to get output.
##               Outout will store in file /tmp/dba_team/mysql_harderning.csv
# Company:       One97
# Usage:         sh Check_MySQL_harderning.sh

#============================================================================

## Get the Server Information like server ip, hostname, uptime, load, server bit , RAM , OS and other.
Server_IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

MySQL_Root_Users_Count=`mysql -uroot  -e 'select count(1) from mysql.user where user = "root";' |  head -3 | tail -1`
MySQL_Blank_Users_Passowrd_Count=`mysql -uroot  -e 'select count(1)from mysql.user  where length(password) = 0 or password is null;' | head -3 | tail -1`
MySQL_Percentage_Users_Count=`mysql -uroot  -e 'select count(1) from mysql.user  where host ="%"' | head -3 | tail -1`
MySQL_Blank_UserName_Count=`mysql -uroot  -e 'select count(1) from mysql.user  where user = ""' | head -3 | tail -1`
MySQL_Users_Week_Passowrd_Count=`mysql -uroot  -e 'select count(1)  from mysql.user where length(password) < 41; ' | head -3 | tail -1`
MySQL_Users_Super_Priv_Count=`mysql -uroot  -e 'select count(1) from mysql.user where Super_priv = "Y" group by user;' | head -3 | tail -1`
MySQL_Create_user_priv_Count=`mysql -uroot  -e 'select count(1) from mysql.user where Create_user_priv = "Y" group by user;' | head -3 | tail -1`

echo MySQL_Root_Users_Count            = $MySQL_Root_Users_Count          ; 
echo MySQL_Blank_Users_Passowrd_Count  = $MySQL_Blank_Users_Passowrd_Count; 
echo MySQL_Percentage_Users_Count      = $MySQL_Percentage_Users_Count    ; 
echo MySQL_Blank_UserName_Count	       = $MySQL_Blank_UserName_Count      ; 
echo MySQL_Users_Week_Passowrd_Count   = $MySQL_Users_Week_Passowrd_Count ; 
echo MySQL_Users_Super_Priv_Count      = $MySQL_Users_Super_Priv_Count    ; 
echo MySQL_Create_user_priv_Count      = $MySQL_Create_user_priv_Count    ; 
echo "${Server_IP}#${MySQL_Root_Users_Count}#${MySQL_Blank_Users_Passowrd_Count}#${MySQL_Percentage_Users_Count}#${MySQL_Blank_UserName_Count}#${MySQL_Users_Week_Passowrd_Count}#${MySQL_Users_Super_Priv_Count}#${MySQL_Create_user_priv_Count}" >> /tmp/mysql_hardening_${Server_IP}.csv
tail -1 /tmp/mysql_hardening_${Server_IP}.csv

