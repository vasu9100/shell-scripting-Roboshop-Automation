#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs dispatch for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 20, 2024
# Version: 1.0

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PINK='\033[0;35m'   # Pink color added
RESET='\033[0m'

# Define variables
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
    echo -e "${PINK}Task Started: $1${RESET}"
    echo "-------------------------------------------------------------------------------------------"
}

# Check if the user is root
if [ "$USER_ID" -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: You are a root user. Script execution will start.${RESET}\n"
else 
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}"
    exit 1
fi

TASK_STARTED "Checking Go-Lang Installed or Not"
echo -e "${YELLOW}GOCHECKING GO-LANG INSTALLED OR NOT\n"
if go version; then
    echo -e "${RED}GO-LANG ALREADY INSTALLED. SKIPPING INSTALLATION.${RESET}\n"
else
    echo -e "${YELLOW}GO-LANG NOT INSTALLED. STARTING INSTALLATION.${RESET}\n"
    dnf install golang -y &>>$LOG_FILE
    VALIDATE $? "Go-Lang Installation"
fi



TASK_STARTED "Checking Robo-Shop User Existence"
echo -e "CHECKING ROBO-SHOP USER EXISTENCE\n"
if id roboshop &>>$LOG_FILE; then
    echo -e "${GREEN}ROBO-SHOP USER ALREADY AVAILABLE. SKIPPING USER CREATION.${GREEN}\n"
else
    echo -e "${YELLOW}ROBO-SHOP USER CREATION STARTED${RESET}\n"
    useradd roboshop &>>$LOG_FILE
    VALIDATE $? "Robo-Shop User Creation"
fi



TASK_STARTED "Checking /app Folder Existence"
echo -e "${YELLOW}GOCHECKING /app FOLDER EXISTENCE\n"
if [ -d /app ]; then
    echo -e "${RED}/app FOLDER ALREADY EXISTS. SKIPPING FOLDER CREATION${RESET}\n"
else
    echo -e "${YELLOW}/app FOLDER CREATION STARTED${RESET}\n"
    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "App Folder Creation"
fi


TASK_STARTED "Downloading the Application Code from Internet"
echo -e "${YELLOW}DOWNLOADING THE APPLICATION CODE FROM INTERNET${RESET}\n"
curl -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOG_FILE
VALIDATE $? "App Code Downloading"



TASK_STARTED "Unzipping the Downloaded App Code"
echo -e "${YELLOW}UNZIPPING THE DOWNLOADED APP CODE${RESET}\n"
cd /app
pwd
VALIDATE $? "Directory Changed into /app"
unzip -o /tmp/dispatch.zip &>>$LOG_FILE
VALIDATE $? "Unzipped Code into /app"


TASK_STARTED "Executing Go-Lang Commands"
echo -e "${YELLOW}GO-LANG COMMANDS EXECUTION STARTED${RESET}\n"
if [ ! -f "/app/go.mod" ]; then
    echo "GO-LANG COMMANDS EXECUTION STARTED\n"  
    go mod init dispatch
    VALIDATE $? "Go-Dispatch"
    go get
    VALIDATE $? "Go-Get"
    go build
    VALIDATE $? "Go-Build"
else
    echo "Already existing go.mod file found."
fi


TASK_STARTED "Copying dispatch.service to /etc/systemd/system"
echo -e "${YELLOW}Copying dispatch.service to /etc/systemd/system${RESET}\n"
cp /home/centos/shell-scripting-Roboshop-Automation/dispatch.service /etc/systemd/system/dispatch.service
VALIDATE $? "Dispatch Service Copying"


TASK_STARTED "Reloading Systemd Daemon"
echo -e "${YELLOW}Reloading systemd daemon${RESET}\n"
systemctl daemon-reload
VALIDATE $? "Daemon Reloaded"

echo -e "${YELLOW}Enabling dispatch service${RESET}\n"
systemctl enable dispatch
VALIDATE $? "Dispatch Service Enabled"


TASK_STARTED "Starting Dispatch Service"
echo -e "${YELLOW}Starting dispatch service${RESET}\n"
systemctl start dispatch
VALIDATE $? "Dispatch Service Started"

echo "SCRIPT END TIME: $0-$DATE"
echo -e "------------------------------ THE-END--------------------------------------\n"

