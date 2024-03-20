#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs NGINX for the Roboshop application.
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
BACKUP="/tmp/HTML-BACKUP-$DATE"

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
echo
echo -e "${GREEN}INSTALLING NGINX"
which nginx &>>$LOG_FILE
if [ $? -eq 0 ]
then
  echo -e "NGNIX IS ALREDAY INSTALLED SO SKIPPING THIS PART"
else
  echo -e "NGINX INSTALLATION PART STARTED"
  dnf install nginx -y &>>$LOG_FILE
  VALIDATE $? "NGINX INSTALLATION PART"
fi
echo "-------------------------------------------------------------------------------------------"  
echo
systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "ENABLED NGINX SERVICE"
echo
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "STARTED NGINX SERVICE"
echo "-----------------------------------------------------------------------------------------------"
echo
echo -e "TAKING BACKUP OF HTML FOLDER"
if [ -d /usr/share/nginx/html ]
then
  echo -e "CREATE BACKUP FOLDER and Taking BAckUp"
  mkdir -p /usr/share/nginx/html &>>$LOG_FILE
  cp -r /usr/share/nginx/html $BACKUP 
  VALIDATE $? "BACKUP FOLDER CREATING BACKUP DONE"
else
  echo -e "${RED}BACKUP"
fi
echo "---------------------------------------------------------------------------------------------"
echo
echo -e "${RED}REMOVING OLD HTML CONTENT${RESET}"
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "OLD HTML DATA REMOVED"
echo
echo -e "${GREEN}Download the frontend content${RESET}"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOG_FILE
VALIDATE $? "DOWNLOADING FRONT-END CODE"
echo
echo -e "${GREEN}EXTRACTING THE CODE ${RESET}"
cd /usr/share/nginx/html
pwd
unzip -o /tmp/web.zip &>>$LOG_FILE
VALIDATE $? "EXTRACTING"
echo "---------------------------------------------------------------------------------------------"
echo
echo "ROBO-SHOP CONFIG FILE STARTED COPYING"
cp /home/centos/shell-scripting-Roboshop-Automation/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
VALIDATE $? "ROBO-SHOP CONFIG FILE COPIED"
echo
systemctl restart nginx
VALIDATE $? "NGINX RESTARTED"
echo -e "$GREEN -----------------------------------THE-END--------------------------------------------------$RESET"
echo -e "${GREEN}SCRIPT EXCEUTION DONE TIME : $DATE"