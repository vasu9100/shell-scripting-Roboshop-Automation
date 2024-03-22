#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs NGINX for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 20, 2024
# Version: 1.0

# Define colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Log file setup
DATE=$(date +'%F-%H-%M-%S')
LOG_FILE="/tmp/$0-$DATE.log"
USER_ID=$(id -u)
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

# Function to print task started message
TASK_STARTED() {
    echo -e "${GREEN}Task Started: $1${RESET}"
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
TASK_STARTED "INSTALLING NGINX"
echo "----------------------------------------------------------------------------------------"

# Check if NGINX is already installed
if command -v nginx &>/dev/null; then
    echo -e "${GREEN}NGINX is already installed.${RESET} Skipping installation."
else
    echo -e "Installing NGINX..."
    dnf install nginx -y &>>$LOG_FILE
    VALIDATE $? "NGINX Installation"
fi

echo
echo "----------------------------------------------------------------------------------------"
TASK_STARTED "CONFIGURING NGINX"
echo "----------------------------------------------------------------------------------------"

# Enable NGINX service
systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling NGINX Service"

# Start NGINX service
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting NGINX Service"

echo
echo "----------------------------------------------------------------------------------------"
TASK_STARTED "TAKING BACKUP OF HTML FOLDER"
echo "----------------------------------------------------------------------------------------"

# Backup HTML folder
if [ -d /usr/share/nginx/html ]; then
    echo -e "Creating backup of HTML folder..."
    mkdir -p $BACKUP &>>$LOG_FILE
    cp -r /usr/share/nginx/html $BACKUP
    VALIDATE $? "Backup HTML Folder"
else
    echo -e "${RED}ERROR: HTML folder not found.${RESET}"
    exit 1
fi

echo
echo "----------------------------------------------------------------------------------------"
TASK_STARTED "REMOVING OLD HTML CONTENT"
echo "----------------------------------------------------------------------------------------"

# Remove old HTML content
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing Old HTML Content"

echo
echo "----------------------------------------------------------------------------------------"
TASK_STARTED "DOWNLOADING FRONT-END CONTENT"
echo "----------------------------------------------------------------------------------------"

# Download frontend content
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOG_FILE
VALIDATE $? "Downloading Frontend Content"

echo
echo "----------------------------------------------------------------------------------------"
TASK_STARTED "EXTRACTING THE CODE"
echo "----------------------------------------------------------------------------------------"

# Extract the downloaded code
cd /usr/share/nginx/html
unzip -o /tmp/web.zip &>>$LOG_FILE
VALIDATE $? "Extracting Code"

echo
echo "----------------------------------------------------------------------------------------"
TASK_STARTED "CONFIGURING ROBOSHOP"
echo "----------------------------------------------------------------------------------------"

# Copy Roboshop config file
cp /home/centos/shell-scripting-Roboshop-Automation/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
VALIDATE $? "Copying Roboshop Config File"

# Restart NGINX service
systemctl restart nginx
VALIDATE $? "Restarting NGINX Service"

echo -e "${GREEN}-----------------------------------THE-END--------------------------------------------------${RESET}"
echo -e "${GREEN}SCRIPT EXECUTION DONE TIME : $DATE${RESET}"
