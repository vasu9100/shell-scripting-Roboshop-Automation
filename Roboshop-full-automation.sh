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

# Define remote commands to execute after copying the folder
remote_commands="sudo sh /home/centos/shell-scripting-Roboshop-Automation/web.sh"

# Get running instance names excluding the specified IP
SERVER_NAMES=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].PublicIpAddress' --output json | jq '.[] | select(. != "50.17.150.240")' | tr -d '"')

# Loop through each instance and execute the script
for name in $SERVER_NAMES;
do
    TASK_STARTED "Executing script on $name"
    echo -e "${YELLOW}LOGGING: ${RESET}$name"
    
    # Copy files to the remote server
    scp -i /home/centos/.ssh/id_rsa -r /home/centos/shell-scripting-Roboshop-Automation centos@$name:/home/centos/
    VALIDATE $? "COPYING DONE $name"
    
    # Execute the script on the remote server
    ssh -i /home/centos/.ssh/id_rsa centos@$name "$remote_commands"
    VALIDATE $? "EXECUTING SCRIPT $name"
done
