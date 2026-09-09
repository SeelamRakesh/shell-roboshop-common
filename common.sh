#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.rakesh.bond
MYSQL_HOST=mysql.rakesh.bond
SCRIPT_START_TIME=$(date +%s) 

mkdir -p $LOG_FOLDER

echo "$(date "+%d-%m-%Y %H:%M:%S") Script execution started at $(date)" | tee -a >> LOG_FILE

check_root(){
 USER_ID=$(id -u)
 if [ $USER_ID -ne 0 ]; then
  echo -e "Run this script as $R Root User $N"
  exit 1
 fi
}

VALIDATE(){
  if [ $1 -ne 0 ]; then
   echo -e "$(date "+%d-%m-%Y %H:%M:%S") | $2 $R FAILURE $N" | tee -a >> LOG_FILE
  else 
   echo -e "$(date "+%d-%m-%Y %H:%M:%S") | $1 $G SUCCESS $N" | tee -a >> LOG_FILE
  fi
}

print_total_time(){
    SCRIPT_END_TIME=$(date +%s)
    TOTAL_TIME=$(($SCRIPT_START_TIME-$SCRIPT_END_TIME))
    echo -e "$(date "+%d-%m-%Y %H:%M:%S") | Script executed in $G $TOTAL_TIME $N" | tee -a >> LOG_FILE
}

