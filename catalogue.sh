#!/bin/bash
# Script Name: install_catalogue.sh
# Purpose: This script installs catalogue for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 20, 2024
# Version: 1.0

# Define colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
    echo -e "${YELLOW}Task Started: $1${RESET}"
}

# Check if the user is root
if [ "$USER_ID" -eq 0 ]; then
    echo -e "${GREEN}SCRIPT START TIME: $DATE${RESET}"
    echo -e "${GREEN}SUCCESS: You are a root user. Script execution will start.${RESET}"
else 
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}"
    exit 1
fi

echo
echo "-----------------------------------------------------------------------------------------------"
TASK_STARTED "DISABLING NODE-JS AND ENABLING LATEST VERSION"
echo "-----------------------------------------------------------------------------------------------"

# Disable and enable Node.js modules
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Node.js Module"
echo
dnf module enable nodejs:18 -y &>>$LOG_FILE
VALIDATE $? "Enabling Node.js 18 Module"

echo
echo "-----------------------------------------------------------------------------------------------"
echo -e "${PINK}Checking Node.js Installation${RESET}"
echo "-----------------------------------------------------------------------------------------------"

# Check Node.js installation
if which node &>/dev/null; then
    echo -e "${GREEN}Node.js already installed.${RESET}"
else
    echo -e "${GREEN}Installing Node.js 18...${RESET}"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Node.js 18 Installation"
fi

echo
echo "-----------------------------------------------------------------------------------------------"
TASK_STARTED "USER SETUP"
echo "-----------------------------------------------------------------------------------------------"

# Check if roboshop user exists
id roboshop &>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Roboshop user already exists.${RESET} Skipping user creation."
else
    echo -e "${GREEN}Creating Roboshop user...${RESET}"
    useradd roboshop &>>$LOG_FILE
    VALIDATE $? "Roboshop User Creation"
fi

echo
echo "-----------------------------------------------------------------------------------------------"
TASK_STARTED "FOLDER SETUP"
echo "-----------------------------------------------------------------------------------------------"

# Check and create /app folder if not exists
if [ -d /app ]; then
    echo -e "${RED}/app folder already exists.${RESET} Skipping folder creation."
else
    echo -e "${YELLOW}/app folder creation started.${RESET}"
    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "/app Folder Creation"
fi

echo
echo "-----------------------------------------------------------------------------------------------"
TASK_STARTED "APPLICATION SETUP"
echo "-----------------------------------------------------------------------------------------------"

# Download and setup the application code
echo -e "${GREEN}Downloading the application code...${RESET}"
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Application Code Download"

echo
echo -e "${GREEN}Unzipping the application code...${RESET}"
cd /app
pwd
unzip -o /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Application Code Unzipping"

echo
echo -e "${GREEN}Installing Node.js dependencies...${RESET}"
npm install &>>$LOG_FILE
VALIDATE $? "Node.js Dependencies Installation"

echo
echo "-----------------------------------------------------------------------------------------------"
TASK_STARTED "SYSTEMD SETUP"
echo "-----------------------------------------------------------------------------------------------"

echo
echo -e "${GREEN}Copying catalogue service file...${RESET}"
cp /home/centos/shell-scripting-Roboshop-Automation/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "Catalogue Service Copy"

# Reload daemon and enable catalogue service
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon Reload"

echo
echo -e "${GREEN}Enabling catalogue service...${RESET}"
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Catalogue Service Enable"

echo
echo -e "${GREEN}Starting catalogue service...${RESET}"
systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "Catalogue Service Start"

echo
echo "-----------------------------------------------------------------------------------------------"
TASK_STARTED "MONGODB SETUP"
echo "-----------------------------------------------------------------------------------------------"

# Setup MongoDB repository and install MongoDB shell
echo -e "${PINK}Setting up MongoDB repository file...${RESET}"
cp /home/centos/shell-scripting-Roboshop-Automation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "MongoDB Repository Setup"

echo
echo -e "${PINK}Verifying MongoDB shell installation...${RESET}"
if mongod --version &>>$LOG_FILE; then
    echo -e "${PINK}MongoDB shell already installed.${RESET} Skipping installation."
else
    echo -e "${PINK}Installing MongoDB shell...${RESET}"
    dnf install mongodb-org-shell -y &>>$LOG_FILE
    VALIDATE $? "MongoDB Shell Installation"
fi

echo
echo -e "${GREEN}Loading catalogue data into MongoDB...${RESET}"
mongo --host mongo.gonepudirobot.online </app/schema/catalogue.js &>>$LOG_FILE
VALIDATE $? "Catalogue Data Loading"

echo
echo -e "${GREEN}Restarting catalogue service...${RESET}"
systemctl restart catalogue &>>$LOG_FILE
VALIDATE $? "Catalogue Service Restart"

echo "------------------------------ THE-END--------------------------------------"
echo -e "${YELLOW}SCRIPT END TIME: $DATE${RESET}"
