#!/bin/bash

source ./common.sh
APP_NAME=frontend
check_root

dnf module list nginx &>>$LOG_FILE
VALIDATE $? "listing Nginx"

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling default Nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx:1.24"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Enabling and Starting Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Zip code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied our nginx conf file"

systemctl restart nginx
VALIDATE $? "Restarted Nginx"

print_total_time