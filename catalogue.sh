#!/bin/bash

source ./common.sh

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo Repo"

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "Installing MongoDB"

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -le 0 ]; then
   mongosh --host $MONGODB_HOST </app/db/master-data.js
   VALIDATE $? "loading master data"
else 
   echo -e "$(date "+%d-%m-%Y %H:%M:%S") | Master data already loaded $N SKIPPING $N"
fi 

print_total_time
  