#!/bin/bash

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

# Remote commands to be executed

# Get running instance names excluding specific IP
SERVER_NAMES=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].PublicIpAddress' --output text | grep -v "50.17.150.240")

# Loop through each instance and execute the script
for name in $SERVER_NAMES;
do
    TASK_STARTED "Executing script on $name"
    echo -e "${YELLOW}LOGGING: ${RESET}$name"
    
    # Copy files to the remote server
    scp -i /home/centos/.ssh/id_rsa -r /home/centos/shell-scripting-Roboshop-Automation centos@$name:/home/centos/
    VALIDATE $? "COPYING DONE $name"
    scp -i /home/centos/.ssh/id_rsa centos@$name:sudo sh /home/centos/shell-scripting-Roboshop-Automation/web.sh
    VALIDATE $? "Script Exceution"
done
