#!/bin/bash

source ./common.sh

check_root
APP_NAME=redis

dnf module disable redis -y
dnf module enable redis:7 -y
VALIDATE $? "Enabling redis:7" 

dnf install redis -y 
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/' -e 's/protected-mode c yes/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis 
systemctl start redis 
VALIDATE $? "Enabling and starting redis" 