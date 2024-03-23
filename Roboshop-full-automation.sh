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
remote_commands="cp -r /home/centos/shell-scripting-Roboshop-Automation /home/centos/shell-scripting-Roboshop-Automation ; cd /home/centos/shell-scripting-Roboshop-Automation; sudo sh web.sh"

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

SERVER_NAMES=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].PublicIpAddress' --output json | jq '.[] | select(. != "50.17.150.240")' | tr -d '"')

# Loop through each instance and execute the script
for name in $SERVER_NAMES;
do
    TASK_STARTED "Executing script on $name"
    echo -e "${YELLOW}LOGGING: ${RESET}$name"
    scp -i /home/centos/.ssh/id_rsa -o "RemoteCommand=$remote_commands" centos@$name
    VALIDATE $? "COPYING DONE $name" 
done

# Get running instance names

