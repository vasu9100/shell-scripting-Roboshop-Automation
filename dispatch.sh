#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs dispatch for the Roboshop application.
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
echo "CHECKING  GO-LANG INSTALLED OR NOT"
if go version
then
    echo -e "${RED}GO-LANG ALREADY INSTALLED SO SKIPPING INSTALLATION"
else
    echo -e "${GREEN}Go-LANG NOT INSTALLED SO STARTED INSTALLATION PART"
    dnf install golang -y &>>$LOG_FILE
    VALIDATE $? "DISPATCH INSTALLATION"
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
curl -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOG_FILE
VALIDATE $? "APP CODE DOWALOADING"
echo
echo -e "${GREEN}UNZIPPING THE DOWNLOAD APP CODE"
cd /app
pwd
VALIDATE $? "DIRECTORY CHANGED INTO APP"
unzip -o /tmp/dispatch.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPED CODE INTO /APP"
echo
echo "GO-LANG COMMANDS EXECUTION STARTED"
if [! -f "/app/go.mod" ]
then
    echo "Alredy Existed go Mod"
else
    echo "GO-LANG COMMANDS EXECUTION STARTED"  
    go mod init dispatch
    VALIDATE $? "Go-Dispatch"
    go get
    VALIDATE $? "Go-Get"
    go build
    VALIDATE $? "Go-BuilD"
fi
echo "-----------------------------------------------------------------------------------------"

echo
cp /home/centos/shell-scripting-Roboshop-Automation/dispatch.service /etc/systemd/system/dispatch.service
VALIDATE $? "Catalogue.service Copying"
echo
systemctl daemon-reload
VALIDATE $? "DAEMON RELOADED"
systemctl enable dispatch
VALIDATE $? "ENABLED DISPATCH SERVICE"
echo
systemctl start dispatch
VALIDATE $? "STARTED DISPATCH SERVICE"
echo "------------------------------ THE-END--------------------------------------"
echo "SCRIPT END TIME: $0-$DATE"