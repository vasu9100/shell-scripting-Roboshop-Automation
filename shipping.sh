#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs catalogue for the Roboshop application.
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

TASK_STARTED "Checking Maven Installed or Not"
yum list installed | grep maven &>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "${GREEN}MAVEN ALREADY INSTALLED.${GREEN}\n"
else
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "MAVEN INSTALLATION"
fi

TASK_STARTED "Creating RoboShop User"
id roboshop &>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "${GREEN}ROBO-SHOP USER ALREADY AVAILABLE. SKIPPING USER CREATION.${GREEN}\n"
else
    useradd roboshop &>>$LOG_FILE
    VALIDATE $? "ROBO-SHOP USER CREATION PART"
fi

TASK_STARTED "Creating App Folder"
if [ -d /app ]; then
    echo -e "{$RED}/app FOLDER ALREADY EXISTED. SKIPPING FOLDER CREATION $RESET\n"
else
    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "APP FOLDER CREATION"
fi

TASK_STARTED "Downloading Shipping Code"
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOG_FILE
VALIDATE $? "SHIPPING CODE DOWNLOADING"

TASK_STARTED "Unzipping Shipping Code"
cd /app
pwd
unzip -o /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPED CODE INTO /APP"

TASK_STARTED "Cleaning Package"
mvn clean package &>>$LOG_FILE
VALIDATE $? "PACKAGE CLEANING"
mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "JAR FILE RENAMED"

TASK_STARTED "Copying Shipping Service File"
cp /home/centos/shell-scripting-Roboshop-Automation/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Shipping Service FILE Copied"

TASK_STARTED "Reloading Systemd Daemon"
systemctl daemon-reload
VALIDATE $? "DAEMON RELOADED"

TASK_STARTED "Enabling Shipping Service"
systemctl enable shipping
VALIDATE $? "ENABLED SHIPPING SERVICE"

TASK_STARTED "Starting Shipping Service"
systemctl start shipping
VALIDATE $? "STARTED SHIPPING SERVICE"

echo -e "-----------------------------------------------------------------------------------------------\n"
echo -e "${GREEN}MYSQL ALREADY INSTALLED. SKIPPING INSTALLATION${RESET}\n"

TASK_STARTED "Loading Shipping Data into MySQL"
mysql -h mysql.gonepudirobot.online -uroot -pRoboShop@1 < /app/schema/shipping.sql
VALIDATE $? "SHIIPING DATA LOADED INTO SQL"

echo -e "${YELLOW}Restarting Shipping Service${RESET}\n"
systemctl restart shipping 
VALIDATE $? "Shipping RESTARTED"

echo -e "------------------------------ THE-END--------------------------------------\n"
echo -e "SCRIPT END TIME: $0-$DATE\n"
