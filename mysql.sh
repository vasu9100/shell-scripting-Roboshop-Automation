#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs MongoDB for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 18, 2024
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
echo "----------------------------------------------------------------------------------"
dnf module disable mysql -y
VALIDATE $? "DISABLING MYSQL DAFUALT VERSION"
echo
echo -e "${GREEN}Setup the MySQL5.7 repo file${RESET}"
cp /home/centos/shell-scripting-Roboshop-Automation/mysql.repo  /etc/yum.repos.d/mysql.repo
VALIDATE $? "MYSQL REPO SETUP"
echo "--------------------------------------------------------------------------------------"
echo
yum list installed | grep mysql

if [ $? -eq 0 ]
then
    echo -e "${YELLOW}MYSQL ALREADY INSTALLED SO SKIIPING INSTALLATION"
else
    dnf install mysql -y
    VALIDATE $? "MYSQL INSTALLATION"
fi
echo "--------------------------------------------------------------------------------------"
echo
systemctl enable mysqld
VALIDATE "systemctl enabled mysqld"
echo
systemctl start mysqld
VALIDATE "systemctl started mysqld"     
echo "----------------------------------------------------------------------------------------"
echo -e "${YELLOW}We need to change the default root password in order to start using the database service"
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "ROOT PASSWORD CHANGED"
echo
echo -e "$GREEN -----------------------------------THE-END--------------------------------------------------$RESET"
echo -e "${GREEN}SCRIPT EXCEUTION DONE TIME : $DATE"

