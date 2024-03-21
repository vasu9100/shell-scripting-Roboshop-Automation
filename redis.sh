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
    if [ "$1" -eq 0 ]; then
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
echo -e "INSTALLING REDIS"
if rpm -q remi-release
then
  echo -e "${RED}REDIS REPO ALREADY INSTALLED SO SKIPPING"
else
  dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
  VALIDATE $? "REDIS RPM INSTALLATION"
fi
echo "----------------------------------------------------------------------------------------"
echo
echo -e "${YELLOW}INSTALLING REDIS NOW"
if systemctl status redis 
then
    echo -e "REDIS ALREADY INSTALLED SO SKIPPING INSTALLATION PART"   
else
    dnf install redis -y
    VALIDATE $? "INSTALLATION REDIS"
fi    
echo "-----------------------------------------------------------------------------------------"
echo
echo -e "${YELLOW}Updating listen address from 127.0.0.1 to 0.0.0.0 in /etc/redis.conf"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "UPDATION LISTEN ADRESS"
echo
systemctl enable redis
VALIDATE $? "REDIS ENABLED"
systemctl start redis
VALIDATE $? "REDIS STARTED"
echo
echo "--------------------------------THE-END--------------------------------------------------------"
echo "${YELLOW}SCRIPT EXCEUTION DONE TIME : $DATE"
