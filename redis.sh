#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs NGINX for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 20, 2024
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

TASK_STARTED "Installing REMI Repository"
echo -e "${YELLOW}Checking if REMI Repository is already installed${RESET}"
if rpm -q remi-release &>>$LOG_FILE; then
  echo -e "${YELLOW}REDIS REPO ALREADY INSTALLED. SKIPPING${RESET}\n"
else
  echo -e "${GREEN}REMI Repository not installed. Installing REMI Repository.${RESET}\n"
  dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG_FILE
  VALIDATE $? "REDIS RPM INSTALLATION"
fi

TASK_STARTED "Installing Redis"
echo -e "${YELLOW}Checking if Redis is already installed${RESET}"
if yum list installed | grep redis; then
    echo -e "${YELLOW}REDIS ALREADY INSTALLED. SKIPPING INSTALLATION.${RESET}\n"   
else
    echo -e "${GREEN}Redis not installed. Installing Redis.${RESET}\n"
    dnf install redis -y &>>$LOG_FILE
    VALIDATE $? "INSTALLATION REDIS"
fi

TASK_STARTED "Updating Listen Address"
echo -e "${YELLOW}Updating listen address from 127.0.0.1 to 0.0.0.0 in /etc/redis.conf${RESET}\n"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
VALIDATE $? "UPDATION LISTEN ADDRESS"

echo -e "${YELLOW}Enabling Redis${RESET}\n"
systemctl enable redis
VALIDATE $? "REDIS ENABLED"

echo -e "${YELLOW}Starting Redis${RESET}\n"
systemctl start redis
VALIDATE $? "REDIS STARTED"

echo -e "${YELLOW}Checking Redis Status${RESET}\n"
netstat -tuln | awk '{print $1, $4}' | grep -i '^tcp'

echo -e "--------------------------------THE-END--------------------------------------------------------\n"
echo -e "${YELLOW}SCRIPT EXECUTION DONE TIME : $DATE${RESET}\n"
