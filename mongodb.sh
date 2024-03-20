#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs MongoDB for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 18, 2024
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

echo "SCRIPT EXECUTION START TIME: $DATE"
echo -e "${YELLOW}MONGO-DB INSTALLATION SCRIPT STARTED TIME: $DATE ${RESET}"
echo "-------------------------------------------------------------------------"
echo -e "${YELLOW}SETTING UP MONGO REPOSITORY FILE${RESET}"
cp /home/centos/shell-scripting-Roboshop-Automation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "MONGO-REPO FILE COPYING"
echo "-------------------------------------------------------------------------"
echo
echo -e "${YELLOW}VERIFYING WHETHER MONGO-DB IS ALREADY INSTALLED ON THE LINUX SYSTEM OR NOT${RESET}"
if which mongod &>>$LOG_FILE; then
    echo -e "${YELLOW}MONGO-DB IS ALREADY INSTALLED. SKIPPING INSTALLATION.${RESET}"
else
    echo -e "${YELLOW}INSTALLING MONGO-DB${RESET}"
    echo
    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? "MONGO-DB INSTALLATION"
fi

echo "-------------------------------------------------------------------------"
echo
echo -e "${YELLOW}STARTING AND ENABLING MONGO-DB${RESET}"
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "MONGO-DB ENABLED"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "MONGO-DB STARTED"

echo "-------------------------------------------------------------------------"
echo
echo -e "${YELLOW}UPDATING LISTEN ADDRESS FROM 127.0.0.1 TO 0.0.0.0${RESET}"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "UPDATED LISTEN ADDRESS"

echo "-------------------------------------------------------------------------"
echo
echo -e "${YELLOW}RESTARTING MONGO-DB${RESET}"
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "MONGO-DB RESTARTED"

echo "-------------------------------------------------------------------------"
echo
echo -e "${YELLOW}CHECKING LISTENER UPDATION${RESET}"
netstat -tuln| grep '^tcp'| awk '{print $1, $4}'
VALIDATE $? "LISTENER UPDATION"

echo "SCRIPT EXECUTION END TIME: $DATE"
echo -e "----------------${RED}THE END ${RESET}--------------------------"
