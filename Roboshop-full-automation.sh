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
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: You are a root user. Script execution will start.${RESET}"
else 
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}"
    exit 1
fi

echo

SERVER_NAMES=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text)

for name in "${SERVER_NAMES}";
do
    echo -e "${YELLOW} LOGGING: ${RESET} $name"
    ssh -i /home/centos/id_rsa centos@$name './web.sh'
    VALIDATE $? "LOGGED INTO : $name"
done  