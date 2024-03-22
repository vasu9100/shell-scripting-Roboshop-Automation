#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs payment for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 20, 2024
# Version: 1.0

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PINK='\033[0;35m'
RESET='\033[0m'
DATE=$(date +'%F-%H-%M-%S')
USER_ID=$(id -u)
LOG_FILE="/tmp/$0-$DATE.log"

# Function to validate commands
VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}SUCCESS: $2${RESET}"
    else
        echo -e "${RED}FAILED: $2${RESET}"
        exit 1
    fi
}
# Function to print task start messages
TASK_STARTED() {
    echo "-------------------------------------------------------------------------------------------"
    echo -e "${PINK}Task Started: $1${RESET}\n"
    echo "-------------------------------------------------------------------------------------------"
}

# Check if the user is root
if [ "$USER_ID" -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: You are a root user. Script execution will start.${RESET}\n"
else 
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}\n"
    exit 1
fi

TASK_STARTED "Checking Python Installation"
echo "CHECKING PYTHON INSTALLED OR NOT"
if python3.6 --version; then
    echo -e "${RED}PYTHON ALREADY INSTALLED. SKIPPING INSTALLATION${RESET}\n"
else
    echo -e "${YELLOW}PYTHON NOT INSTALLED. STARTING INSTALLATION${RESET}\n"
    dnf install python36 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "PYTHON INSTALLATION"
fi

TASK_STARTED "User Creation"
id roboshop &>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "${YELLOW}ROBO-SHOP USER ALREADY AVAILABLE. SKIPPING USER CREATION${RESET}\n"
else
    echo -e "${YELLOW}ROBO-SHOP USER CREATION STARTED${RESET}\n"
    useradd roboshop &>>$LOG_FILE
    VALIDATE $? "ROBO-SHOP USER CREATION PART"
fi

TASK_STARTED "Creating App Folder"
if [ -d /app ]; then
    echo -e "${RED}/app FOLDER ALREADY EXISTS. SKIPPING FOLDER CREATION${RESET}\n"
else
    echo -e "${YELLOW}/app FOLDER CREATION STARTED${RESET}\n"
    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "APP FOLDER CREATION"
fi

TASK_STARTED "Downloading Application Code"
echo -e "${YELLOW}DOWNLOADING THE APPLICATION CODE FROM INTERNET${RESET}\n"
curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOG_FILE
VALIDATE $? "APP CODE DOWNLOADING"

TASK_STARTED "Unzipping Application Code"
echo -e "${YELLOW}UNZIPPING THE DOWNLOADED APP CODE${RESET}\n"
cd /app
pwd
unzip -o /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPED CODE INTO /APP"

TASK_STARTED "Installing Dependencies"
echo -e "${YELLOW}PIP INSTALLATION STARTED${RESET}\n"
pip3.6 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "PIP 3.6 INSTALLATION"

echo -e "-----------------------------------------------------------------------------------------\n"

echo -e "${YELLOW}Copying payment.service to /etc/systemd/system${RESET}\n"
cp /home/centos/shell-scripting-Roboshop-Automation/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Payment Service Copying"

echo -e "${YELLOW}Reloading systemd daemon${RESET}\n"
systemctl daemon-reload
VALIDATE $? "Daemon Reloaded"

echo -e "${YELLOW}Enabling payment service${RESET}\n"
systemctl enable payment
VALIDATE $? "Payment Service Enabled"

echo -e "${YELLOW}Starting payment service${RESET}\n"
systemctl start payment
VALIDATE $? "Payment Service Started"
echo -e "SCRIPT END TIME: $0-$DATE\n"
echo -e "------------------------------ THE-END--------------------------------------\n"

