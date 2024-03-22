#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs user for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 20, 2024
# Version: 1.0

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PINK='\033[0;35m'   # Pink color added
RESET='\033[0m'
DATE=$(date +'%F-%H-%M-%S')
USER_ID=$(id -u)
LOG_FILE="/tmp/$0-$DATE.log"

# Function to validate commands
VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "${YELLOW}$2... ${GREEN}SUCCESS${RESET}"
    else
        echo -e "${YELLOW}$2... ${RED}FAILED${RESET}"
        exit 1
    fi
}

# Function to print task start messages
TASK() {
    TASK_NAME="$1"
    echo "-------------------------------------------------------------------------------------------"
    echo -e "${PINK}Task: $TASK_NAME${RESET}"
    echo "-------------------------------------------------------------------------------------------"
}

# Check if the user is root
if [ "$USER_ID" -eq 0 ]; then
    TASK "Root User Verification"
    echo -e "${GREEN}SUCCESS: You are a root user.${RESET}"
else 
    TASK "Root User Verification"
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}"
    exit 1
fi
echo

TASK "Node.js Installation"
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLED NODE-JS"
dnf module enable nodejs:18 -y &>>$LOG_FILE
VALIDATE $? "ENABLED NODE-JS"
which node
if [ $? -eq 0 ]; then
    echo -e "${GREEN}NODE JS ALREADY INSTALLED ${GREEN}"
else
    echo -e "${GREEN}NODE JS 18 INSTALLING"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "NODEJS-18 INSTALLATION"
fi

TASK "User Creation"
id roboshop &>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "${GREEN}ROBO-SHOP USER ALREADY AVAILABLE So SKIIPING USER CREATION ${GREEN}"
else
    echo -e "${GREEN}ROBO-SHOP USER CREATION STARTED"
    useradd roboshop &>>$LOG_FILE
    VALIDATE $? "ROBO-SHOP USER CREATION PART"
fi

TASK "Folder Creation"
if [ -d /app ]; then
    echo -e "{$RED}/app FOLDER ALREADY EXISTED SO SKIPPING FOLDER CREATION $RESET"
else
    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "APP FOLDER CREATION"
fi

TASK "Application Code Download"
curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOG_FILE
VALIDATE $? "APP CODE DOWALOADING"

TASK "Unzipping Application Code"
cd /app
unzip -o /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPED CODE INTO /APP"

TASK "NPM Installation"
npm install &>>$LOG_FILE
VALIDATE $? "NPM INSTALLATION"

TASK "Daemon Reload"
systemctl daemon-reload
VALIDATE $? "DAEMON RELOADED"

TASK "Copy Service File"
cp /home/centos/shell-scripting-Roboshop-Automation/user.service /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATE $? "user.service Copying"

TASK "Enable User Service"
systemctl enable user
VALIDATE $? "ENABLED USER SERVICE"

TASK "Start User Service"
systemctl start user
VALIDATE $? "STARTED USER SERVICE"

TASK "Mongo Repository Setup"
cp /home/centos/shell-scripting-Roboshop-Automation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "MONGO-REPO FILE COPYING"

TASK "MongoDB Installation"
if mongod --version &>>$LOG_FILE; then
    echo -e "${YELLOW}MONGO-DB IS ALREADY INSTALLED. SKIPPING INSTALLATION.${RESET}"
else
    dnf install mongodb-org-shell -y &>>$LOG_FILE
    VALIDATE $? "MONGO-DB-ORG-SHELL INSTALLATION"
fi

TASK "Loading Catalogue Data into MongoDB"
mongo --host mongo.gonepudirobot.online </app/schema/user.js &>>$LOG_FILE
VALIDATE $? "DATA UPLOADING"

TASK "Restart User Service"
systemctl restart user
VALIDATE $? "USER RESTARTED"

echo "------------------------------ THE-END--------------------------------------"
echo "SCRIPT END TIME: $0-$DATE"
