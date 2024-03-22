#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs MongoDB for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 18, 2024
# Version: 1.0

# Define colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PINK='\033[1;35m'
RESET='\033[0m'

# Log file setup
DATE=$(date +'%F-%H-%M-%S')
LOG_FILE="/tmp/$0-$DATE.log"
USER_ID=$(id -u)

# Function to validate commands
VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "${YELLOW}$2... ${GREEN}SUCCESS${RESET}"
    else
        echo -e "${YELLOW}$2... ${RED}FAILED${RESET}"
        exit 1
    fi
}

# Function to print task started message
TASK_STARTED() {
    echo "-------------------------------------------------------------------------------------------"
    echo -e "${PINK}Task Started: $1${RESET}"
    echo "--------------------------------------------------------------------------------------------"
}

# Check if the user is root
if [ "$USER_ID" -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: You are a root user. Script execution will start.${RESET}"
else 
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}"
    exit 1
fi

echo -e "${YELLOW}SCRIPT EXECUTION START TIME: $DATE${RESET}"
echo -e "${PINK}MONGO-DB INSTALLATION SCRIPT STARTED TIME: $DATE ${RESET}"


# Setup MongoDB repository
TASK_STARTED "SETTING UP MONGO REPOSITORY FILE"
cp /home/centos/shell-scripting-Roboshop-Automation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "MONGO-REPO FILE COPYING"


# Check if MongoDB is already installed
TASK_STARTED "VERIFYING WHETHER MONGO-DB IS ALREADY INSTALLED ON THE LINUX SYSTEM OR NOT"
if which mongod &>>$LOG_FILE; then
    echo -e "${YELLOW}MONGO-DB IS ALREADY INSTALLED. SKIPPING INSTALLATION.${RESET}"
else
    TASK_STARTED "INSTALLING MONGO-DB"
    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? "MONGO-DB INSTALLATION"
fi



# Start and enable MongoDB
TASK_STARTED "STARTING AND ENABLING MONGO-DB"
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "MONGO-DB ENABLED"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "MONGO-DB STARTED"



# Update listen address from 127.0.0.1 to 0.0.0.0
TASK_STARTED "UPDATING LISTEN ADDRESS FROM 127.0.0.1 TO 0.0.0.0"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "UPDATED LISTEN ADDRESS"



# Restart MongoDB
TASK_STARTED "RESTARTING MONGO-DB"
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "MONGO-DB RESTARTED"



# Check listener updation
TASK_STARTED "CHECKING LISTENER UPDATION"
netstat -tuln | grep '^tcp' | awk '{print $1, $4}'
VALIDATE $? "LISTENER UPDATION"

echo -e "${YELLOW}SCRIPT EXECUTION END TIME: $DATE${RESET}"
echo -e "----------------${PINK}THE END ${RESET}--------------------------"
