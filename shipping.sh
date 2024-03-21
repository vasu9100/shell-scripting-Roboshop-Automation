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
echo -e "${GREEN}CHECKING MAVEN INSTALLED OR NOT ${RESET}"
yum list installed | grep maven &>>$LOG_FILE
if [ $? -eq 0 ]
then
    echo -e "${GREEN}MAVEN ALREADY INSTALLED ${GREEN}"
else
    echo -e "${GREEN}MAVEN NOT INSTALLED SO INSTALLING MAVEN"
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "MAVEN INSTALLATION"
fi
echo "----------------------------------------------------------------------------------"
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
echo -e "${GREEN}DOWNLOADING THE SHIPPING CODE FROM INTERNET ${RESET}"
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOG_FILE
VALIDATE $? "SHIPPING CODE DOWALOADING"
echo
echo -e "${GREEN}UNZIPPING THE DOWNLOAD SHIPPING CODE"
cd /app
pwd
unzip -o /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPED CODE INTO /APP"
echo
echo -e "${GREEN}PACKAGE CLEANING STARTED $RESET"
mvn clean package
VALIDATE $? "PACAKGE CLEANING"
mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "JAR FILE RENAMED"
echo "-----------------------------------------------------------------------------------------"
echo
cp /home/centos/shell-scripting-Roboshop-Automation/shipping.service /etc/systemd/system/shipping.service
VALIDATE "Shipping Service FILE Copied"
echo
systemctl daemon-reload
VALIDATE $? "DAEMON RELOADED"
systemctl enable shipping
VALIDATE $? "ENABLED SHIPPING SERVICE"
echo
systemctl start shipping
VALIDATE $? "STARTED SHIPPING SERVICE"
echo
echo "-----------------------------------------------------------------------------------------------"
echo
yum list installed | grep mysql &>>$LOG_FILE

if [ $? -eq 0 ]
then
    echo -e "${YELLOW}MYSQL ALREADY INSTALLED SO SKIIPING INSTALLATION"
else
    dnf install mysql -y &>>$LOG_FILE
    VALIDATE $? "MYSQL INSTALLATION"
fi
echo "----------------------------------------------------------------------------------------------"
echo
mysql -h mysql.gonepudirobot.online -uroot -pRoboShop@1 < /app/schema/shipping.sql
VALIDATE $? "SHIIPING DATA LOADED INTO SQL"

systemctl restart shipping 
VALIDATE $? "Shipping RESTARTED"

echo "------------------------------ THE-END--------------------------------------"
echo "SCRIPT END TIME: $0-$DATE"