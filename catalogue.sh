#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs catalogue for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 20, 2024
# Version: 1.0

# Define variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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

# Check if the user is root
if [ "$USER_ID" -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: You are a root user. Script execution will start.${RESET}"
else 
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}"
    exit 1
fi
echo
echo "----------------------------------------------------------------------------------------"
echo -e "${GREEN}DISABLING NODE-JS AND ENABLING LATEST VERSION ${RESET}"
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLED NODE-JS"
echo
dnf module enable nodejs:18 -y &>>$LOG_FILE
VALIDATE $? "ENABLED NODE-JS"
echo "-----------------------------------------------------------------------------------------"
echo -e "${YELLOW}$0 is checking Node-js whether installed or not in the system ${RESET}"
which node
if [ $? -eq 0 ]
then
    echo -e "${GREEN}NODE JS ALREADY INSTALLED ${GREEN}"
else
    echo -e "${GREEN}NODE JS 18 INSTALLING"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "NODEJS-18 INSTALLATION"
fi
echo "-------------------------------------------------------------------------------------------"
echo
id roboshop &>>$LOG_FILE
if [ $? -eq 0 ]
then
    echo -e "${GREEN}ROBO-SHOP USER ALREADY AVAILABLE So SKIIPING USER CREATION ${GREEN}"
else
    echo -e "${GREEN}ROBO-SHOP USER CREATION STARTED"
    useradd roboshop &>>$LOG_FILE
    VALIDATE $? "ROBO-SHOP USER CREATION PART"
fi
echo "--------------------------------------------------------------------------------------------"
echo
if [ -d /app ]
then
    echo -e "{$RED}/app FOLDER ALREADY EXISTED SO SKIPPING FOLDER CREATION $RESET"
else
    echo -e "${YELLOW}/app FOLDER CREATION STARTED $RESET"
    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "APP FOLDER CREATION"
fi
echo "-------------------------------------------------------------------------------------------"
echo
echo -e "${GREEN}DOWNLOADING THE APPLICATION CODE FROM INTERNET ${RESET}"
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOG_FILE
VALIDATE $? "APP CODE DOWALOADING"
echo
echo -e "${GREEN}UNZIPPING THE DOWNLOAD APP CODE"
cd /app
pwd
unzip -o /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPED CODE INTO /APP"
echo
echo -e "${GREEN}NPM INSTALLATION STARTED $RESET"
echo "-----------------------------------------------------------------------------------------"
echo
systemctl daemon-reload
VALIDATE $? "DAEMON RELOADED"
echo
cp /home/centos/shell-scripting-Roboshop-Automation/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Catalogue.service Copying"
systemctl enable catalogue
VALIDATE $? "ENABLED CATALOGUE SERVICE"
echo
systemctl start catalogue
VALIDATE $? "STARTED CATALOGUE SERVICE"
echo "-----------------------------------------------------------------------------------------------"
echo
echo -e "${YELLOW}SETTING UP MONGO REPOSITORY FILE${RESET}"
cp /home/centos/shell-scripting-Roboshop-Automation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "MONGO-REPO FILE COPYING"
echo "-------------------------------------------------------------------------"
echo
echo -e "${YELLOW}VERIFYING WHETHER MONGO-DB-ORG-SHELL IS ALREADY INSTALLED ON THE LINUX SYSTEM OR NOT${RESET}"
if mongod --version &>>$LOG_FILE; then
    echo -e "${YELLOW}MONGO-DB IS ALREADY INSTALLED. SKIPPING INSTALLATION.${RESET}"
else
    echo -e "${YELLOW}INSTALLING MONGO-DB${RESET}"
    echo
    dnf install mongodb-org-shell -y &>>$LOG_FILE
    VALIDATE $? "MONGO-DB-ORG-SHELL INSTALLATION"
fi
echo "---------------------------------------------------------------------------"
echo
echo -e "${GREEN}LOADING CATALOGUE DATA INTO MONGO-DB"
mongo --host mongo.gonepudirobot.online </app/schema/catalogue.js &>>$LOG_FILE
VALIDATE $? "DATA UPLOADING"
systemctl restart catalogue
VALIDATE $? "CATALOGUE RESTARTED"

echo "------------------------------ THE-END--------------------------------------"
echo "SCRIPT END TIME: $0-$DATE"