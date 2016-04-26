#!/bin/bash

#debug on\off
set -x

#allvalues
user="user"
homedir="/home/user"
date=$(date +"%d-%m-%Y")

#redis values#############
redishost="<<IP>>"
redisport="6379"
redishome="redisdump"
redisdir="/mnt/redis"
redisconf="/etc/redis.conf"
rconf="redis.conf"
rdump="dump.rdb"
list=$(redis-cli -h $redishost -p $redisport cluster nodes | grep -Fv "disconnected" | awk '/master/{IP=$2; sub(":.*$","",IP); print IP})

#manual list hosts
#"

start=0
ver=$(ls $dir | head -1)
##########################

#mongo section############
mongohost="ip"
mongoport="27017"
mongouser="test_user"
mongopass="Cah"
mongodb="srv_test"
mongodumppath="mongodump"
datemongo=$(date +"%d-%m-%Y")
###########################

#mkdirs###################
if [ -d "$mongodumppath" ]; then
echo ""
else
mkdir $mongodumppath
fi
##########################

#####colors################
Green='\033[0;32m'        # Green
###########################




#Functions

function rrestore
 {
 keys=$(ls -l $redishome/$redisdate| wc -l)
 if [[ "$keys" > "4" ]];
    then
    echo "Too many keys. check $redishome/$redisdate"
    else
    echo -e "\x1B[01;99m"
     echo "Master nodes are:" 
     echo $list
     echo -e "\x1B[0m"
     for i in $list
        do
        let "start += 1"
        let "stat = start"
        echo -e "\x1B[01;91m Started restore procedure on $i \x1B[0m"
        echo -e "\x1B[32m"
        ssh $user@$i "sudo /etc/init.d/redis6004 stop"
        ssh $user@$i "sudo /etc/init.d/redis6005 stop"
        ssh $user@$i "sudo rm -f $redisdir/$rdump"
        ssh $user@$i "sudo rm -f $redisdir/appendonly.aof"
        ssh $user@$i "sudo rm -f $homedir/*.rdb"
        ssh $user@$i "sudo cp $redisconf $redisconf.yesappend"
        ssh $user@$i "sudo sed 's/appendonly yes/appendonly no/g' $redisconf >> $homedir/$rconf.noappend"
        ssh $user@$i "sudo mv $homedir/$rconf.noappend $redisconf"
        redisdmp=`ls -1 $redishome/$redisdate | grep rdb | sed -n "${stat}p"`
        scp $redishome/$redisdate/$redisdmp  $user@$i:
        ssh $user@$i "sudo cp $homedir/$redisdmp $redisdir/$rdump"
        ssh $user@$i "sudo chown redis:redis $redisdir/$rdump"
        ssh $user@$i "sudo chown redis:redis $redisconf"
        ssh $user@$i "sudo /etc/init.d/redis6005 start"
        ssh $user@$i "sudo /etc/init.d/redis6004 start"
        ssh $user@$i "sudo redis-cli -p 6004 BGREWRITEAOF"
        sleep 5
        ssh $user@$i "sudo /etc/init.d/redis6004 stop"
        ssh $user@$i "sudo /etc/init.d/redis6005 stop"
        ssh $user@$i "sudo mv $redisconf.yesappend $redisconf"
        ssh $user@$i "sudo chown redis:redis $redisconf"
        ssh $user@$i "sudo rm -f $redisdir/$rdump"
        ssh $user@$i "sudo /etc/init.d/redis6005 start \x1B[0m"
        ssh $user@$i "sudo /etc/init.d/redis6004 start \x1B[0m"
        echo -e "\x1B[0m"
        echo -e "\x1B[01;91m Ended restore procedure on $i \x1B[0m"
        done
 fi
 }

function mrestore
 {
 echo -e "\x1B[01;91m Started mongodb data reserve backup operation \x1B[0m"
 mongodump --db $mongodb --host $mongohost:$mongoport --username $mongouser --password $mongopass --out reserve/$date
 echo -e "\x1B[01;91m Reserve operation: Done \x1B[0m"
 echo -e "\x1B[01;91m Started restore \x1B[0m"
 mongorestore --db $mongodb --host $mongohost:$mongoport --username $mongouser --password $mongopass $mongodumppath/$dumpmongo/$mongodb --drop
 echo -e "\x1B[01;91m Finished restore \x1B[0m"
 break
 }


function opt1
{
   opt1=""
   date1=`date +"%m-%d-%Y_%H:%M"`
   while [ "$subopt1" != "x" ]
   do
   if [ -d "$redishome" ]; then
   mkdir $redishome/$date
   else
   mkdir $redishome
   mkdir $redishome/$date
   fi
   echo -e "Backup started"
   rm -f $redishome/$date/*
   list=`redis-cli -h $redishost -p $redisport cluster nodes | grep master |grep -Fv dis | awk '{print $2}' | sed 's/:.*//'`
   for i in $list
   do
    ssh $user@$i "sudo redis-cli SAVE"
    sleep 5
    ssh $user@$i "sudo mv $redisdir/$rdump $homedir/$i.$date.$rdump"
    scp $user@$i:$i.$date.$rdump $redishome/$date/
   done
   break
   done
 }

function opt2
 {
     opt2=""
     while [ "$subopt2" != "x" ]
     do
     mongodump --host $mongohost --port $mongoport --username $mongouser --password $mongopass --db $mongodb --out $mongodumppath/$date
     break
     done
 }

function opt3
 {
     opt3=""
     while [ "$subopt3" != "x" ]
     do
     echo "Choose ur last 10 backups.User from 1 to 10"
     ls -1 $redishome
     read -p "" opt3
    if [ "$opt3" = "1" ]; then
        redisdate=`ls -l $redishome | sed -n 2p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "2" ]; then
        redisdate=`ls -l $redishome | sed -n 3p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "3" ]; then
        redisdate=`ls -l $redishome | sed -n 4p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "4" ]; then
        redisdate=`ls -l $redishome | sed -n 5p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "5" ]; then
        redisdate=`ls -l $redishome | sed -n 6p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "6" ]; then
        redisdate=`ls -l $redishome | sed -n 7p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "7" ]; then
        redisdate=`ls -l $redishome | sed -n 8p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "8" ]; then
        redisdate=`ls -l $redishome | sed -n 9p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "9" ]; then
        redisdate=`ls -l $redishome | sed -n 10p | awk '{print $9}'`
             rrestore
        elif [ "$opt3" = "10" ]; then
        redisdate=`ls -l $redishome | sed -n 11p | awk '{print $9}'`
             rrestore
        fi
     break
     done
 }
function opt4
 {
     opt4=""
     while [ "$subopt4" != "x" ]
     do
     echo "Choose ur last 10 backups. Use from 1 to 10"
     ls -1 $mongodumppath
     read -p "" opt4
    if [ "$opt4" = "1" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 2p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "2" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 3p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "3" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 4p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "4" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 5p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "5" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 6p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "6" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 7p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "7" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 8p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "8" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 9p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "9" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 10p | awk '{print $9}'`
             mrestore
             break
        elif [ "$opt4" = "10" ]; then
             dumpmongo=`ls -l $mongodumppath | sed -n 11p | awk '{print $9}'`
             mrestore
             break
        fi
    break
     done
 }
function opt5
 {
     opt5=""
     while [ "$subopt5" != "x" ]
     do
     ls -l $redishome
     break
     done
 }

function opt6
 {
     opt6=""
     while [ "$subopt6" != "x" ]
     do
     ls -l $mongodumppath
     break
     done
 }

function opt7
 {
     opt7=""
     versionlist=`redis-cli -h $redishost -p $redisport cluster nodes | awk '{print $2}' | sed 's/:.*//'`
     for ii in $versionlist
     do
     echo "Redis version of $ii :"
     redis-cli -h $ii -p $redisport --version
     done
 }

function opt8
 {
    slavesstart
 }


function mainopt
 {
    opt=""
    while [ "$opt" != "x" ]
    do  
	echo -e "\x1B[01;94m"
        echo ===============================
        echo 1. Backup Redis		
        echo 2. Backup Mongo		
        echo 3. Restore Redis		
        echo 4. Restore Mongo		
        echo 5. List avaliable backups Redis
        echo 6. List avaliable backups Mongo
        echo 7. Show Redis[es] Version
        echo 0. Exit
        echo ===============================
        echo -e "\x1B[0m"
        read -p "Select Otion: " opt
        if [ "$opt" = "1" ]; then
             opt1
        elif [ "$opt" = "2" ]; then
             opt2
        elif [ "$opt" = "3" ]; then
             opt3
        elif [ "$opt" = "4" ]; then
             opt4
        elif [ "$opt" = "5" ]; then
             opt5
        elif [ "$opt" = "6" ]; then
             opt6
        elif [ "$opt" = "7" ]; then
             opt7
        elif [ "$opt" = "0" ]; then
             break
        fi
   done
}

mainopt
