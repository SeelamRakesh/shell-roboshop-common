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

echo "$(date "+%d-%m-%Y %H:%M:%S") Script execution started at $(date)" | tee -a $LOG_FILE

check_root(){
 if [ $USER_ID -ne 0 ]; then
  echo -e "Run this script as $R Root User $N"
  exit 1
 fi
}

VALIDATE(){
  if [ $1 -ne 0 ]; then
   echo -e "$(date "+%d-%m-%Y %H:%M:%S") | $2 $R FAILURE $N" | tee -a $LOG_FILE
   exit 1
  else 
   echo -e "$(date "+%d-%m-%Y %H:%M:%S") | $2 $G SUCCESS $N" | tee -a $LOG_FILE
  fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $LOG_FILE
    VALIDATE $? "Disabling Nodejs"

    dnf module enable nodejs:20 -y &>> $LOG_FILE
    VALIDATE $? "Enabling Nodejs:20"

    dnf install nodejs -y &>> $LOG_FILE
    VALIDATE $? "Installing Nodejs"
    
    npm install &>> $LOG_FILE
    VALIDATE $? "Installing Dependencies" 
}

app_setup(){
    id roboshop
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Adding system user"
    else
      echo -e "System User already exists $Y SKYPPING $N"
    fi

    mkdir -p /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
    VALIDATE $? "Downloding application code"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    cd /app 
    unzip /tmp/catalogue.zip &>> $LOG_FILE
    VALIDATE $? "Unzipping catalogue code"

}

systemd_setup(){
    cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
    VALIDATE $? "Copying catalogue service"

    systemctl enable catalogue 
    systemctl start catalogue
    VALIDATE $? "Enabling and staring Catalogue"
}

print_total_time(){
    SCRIPT_END_TIME=$(date +%s)
    TOTAL_TIME=$(($SCRIPT_END_TIME - $SCRIPT_START_TIME))
    echo -e "$(date "+%d-%m-%Y %H:%M:%S") | Script executed in $G $TOTAL_TIME $N" | tee -a $LOG_FILE
}

