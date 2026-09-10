#!/bin/bash

source ./common.sh

check_root
APP_NAME=redis

dnf module disable redis -y &>> $LOG_FILE
dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "Enabling redis:7" 

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>> $LOG_FILE
systemctl start redis 
VALIDATE $? "Enabling and starting redis" 