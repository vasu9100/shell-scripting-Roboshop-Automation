#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs payment for the Roboshop application.
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
echo "CHECKING PYTHON INSTALLED OR NOT"
if python -V
then
    echo -e "${RED}PYTHON ALREADY INSTALLED SO SKIPPING INSTALLATION"
else
    echo -e "${GREEN}PYTHON NOT INSTALLED SO STARTED INSTALLATION PART"
    dnf install python36 gcc python3-devel -y
    VALIDATE $? "PYTHON INSTALLATION"
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
curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOG_FILE
VALIDATE $? "APP CODE DOWALOADING"
echo
echo -e "${GREEN}UNZIPPING THE DOWNLOAD APP CODE"
cd /app
pwd
unzip -o /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPED CODE INTO /APP"
echo
echo -e "${GREEN}NPM INSTALLATION STARTED $RESET"
pip3.6 install -r requirements.txt
VALIDATE $? "PIP 3.6 INSTALLATION"
echo "-----------------------------------------------------------------------------------------"

echo
cp /home/centos/shell-scripting-Roboshop-Automation/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Catalogue.service Copying"
echo
systemctl daemon-reload
VALIDATE $? "DAEMON RELOADED"
systemctl enable payment
VALIDATE $? "ENABLED PAYMENT SERVICE"
echo
systemctl start payment
VALIDATE $? "STARTED PAYMENT SERVICE"
echo "------------------------------ THE-END--------------------------------------"
echo "SCRIPT END TIME: $0-$DATE"