#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs MongoDB for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 18, 2024
# Version: 1.0

# Define colors
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
        echo -e "${YELLOW}$2... ${GREEN}SUCCESS${RESET}\n"
    else
        echo -e "${YELLOW}$2... ${RED}FAILED${RESET}\n"
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
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}"
    exit 1
fi

TASK_STARTED "Disabling MySQL Default Version"
dnf module disable mysql -y &>>$LOG_FILE
VALIDATE $? "DISABLING MYSQL DEFAULT VERSION"

TASK_STARTED "Setting Up MySQL 5.7 Repo"
cp /home/centos/shell-scripting-Roboshop-Automation/mysql.repo  /etc/yum.repos.d/mysql.repo &>>$LOG_FILE
VALIDATE $? "MYSQL REPO SETUP"

TASK_STARTED "Checking Installed MySQL Packages"
yum list installed | grep mysql &>>$LOG_FILE

if [ $? -eq 0 ]; then
    echo -e "${YELLOW}MYSQL ALREADY INSTALLED. SKIPPING INSTALLATION${RESET}\n"
else
    dnf install mysql -y &>>$LOG_FILE
    VALIDATE $? "MYSQL INSTALLATION"
fi

dnf install mysql-community-server -y &>>$LOG_FILE
VALIDATE $? "COMMUNITY SERVER INSTALLED"

TASK_STARTED "Enabling MySQL Service"
systemctl enable mysqld
VALIDATE $? "Enabled mysqld"

TASK_STARTED "Starting MySQL Service"
systemctl start mysqld
VALIDATE $? "Started mysqld"

TASK_STARTED "Changing Root Password"
echo -e "${YELLOW}We need to change the default root password in order to start using the database service${RESET}\n"
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "ROOT PASSWORD CHANGED"

echo -e "${GREEN}-----------------------------------THE-END--------------------------------------------------${RESET}\n"
echo -e "${GREEN}SCRIPT EXECUTION DONE TIME: $DATE${RESET}"
