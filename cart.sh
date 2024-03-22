#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs cart for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 20, 2024
# Version: 1.0

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PINK='\033[0;35m'
RESET='\033[0m'

# Define variables
DATE=$(date +'%F-%H-%M-%S')
USER_ID=$(id -u)
LOG_FILE="/tmp/$0-$DATE.log"

# Function to print task start messages
TASK_STARTED() {
    echo "-------------------------------------------------------------------------------------------"
    echo -e "${PINK}Task Started: $1${RESET}"
    echo "-------------------------------------------------------------------------------------------"
}

# Function to validate commands
VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}SUCCESS: $2${RESET}"
    else
        echo -e "${RED}FAILED: $2${RESET}"
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

TASK_STARTED "Disabling Node.js and enabling the latest version"
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabled Node.js"
dnf module enable nodejs:18 -y &>>$LOG_FILE
VALIDATE $? "Enabled Node.js"

echo

echo -e "${YELLOW}Checking if Node.js is installed${RESET}"
which node
if [ $? -eq 0 ]
then
    echo -e "${GREEN}SUCCESS: Node.js is already installed.${RESET}"
else
    TASK_STARTED "Installing Node.js 18"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Node.js 18 Installation"
fi

echo

id roboshop &>>$LOG_FILE
if [ $? -eq 0 ]
then
    echo -e "${GREEN}SUCCESS: Robo-shop user already exists. Skipping user creation.${RESET}"
else
    TASK_STARTED "Creating Robo-shop user"
    useradd roboshop &>>$LOG_FILE
    VALIDATE $? "Robo-shop user creation"
fi

echo

if [ -d /app ]
then
    echo -e "${RED}SUCCESS: /app folder already exists. Skipping folder creation.${RESET}"
else
    TASK_STARTED "Creating /app folder"
    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "/app folder creation"
fi

echo

echo -e "${GREEN}Downloading the application code from the internet.${RESET}"
curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOG_FILE
VALIDATE $? "Application code downloading"

echo

TASK_STARTED "Unzipping the downloaded application code"
cd /app
pwd
unzip -o /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "Unzipped code into /app"

echo

echo -e "${GREEN}NPM installation started.${RESET}"
npm install &>>$LOG_FILE
VALIDATE $? "NPM installation"

echo

systemctl daemon-reload
VALIDATE $? "Daemon reloaded"

echo

TASK_STARTED "Copying cart.service to /etc/systemd/system"
cp /home/centos/shell-scripting-Roboshop-Automation/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copied cart.service"

systemctl enable cart
VALIDATE $? "Enabled cart service"

echo

systemctl start cart
VALIDATE $? "Started cart service"

echo

systemctl restart cart
VALIDATE $? "Restarted cart service"

echo "------------------------------ THE-END--------------------------------------"
echo "SCRIPT END TIME: $0-$DATE"
