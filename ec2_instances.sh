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

SERVER_NAMES=("web" "catalogue" "cart" "mongo" "user" "redis" "mysql" "shipping" "rabbit" "payment" "dispatch")
SECURITY_GROUP_ID="sg-0eab7d3878626d44d"
AMI="ami-0f3c7d07486cad139"
SMALL_INSTANCES="t2.micro"
BIG_INSTANCES="t3.small"

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
TASK_STARTED "EC2 INSTANCES STARTED CREATING"

for name in "${SERVER_NAMES[@]}";
do
    if [ "$name" = "mysql" ] || [ "$name" = "mongo" ] || [ "$name" = "shipping" ]; then
        echo -e "INSTANCE IS-->${name} SO INSTANCE TYPE IS t2.small"
        INSTANCE=$(aws ec2 run-instances \
            --image-id "$AMI" \
            --instance-type "$BIG_INSTANCES" \
            --security-group-ids "$SECURITY_GROUP_ID" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$name}]"\
            --query 'Instances[0].PrivateIpAddress' \
            --output text)
        #sleep 10    
        echo "Public IP of $name is: $INSTANCE"
    else
        echo -e "INSTANCE IS-->${name} SO INSTANCE TYPE IS t2.micro"
        INSTANCE=$(aws ec2 run-instances \
            --image-id "$AMI" \
            --instance-type "$SMALL_INSTANCES" \
            --security-group-ids "$SECURITY_GROUP_ID" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$name}]" \
            --query 'Instances[0].PrivateIpAddress' \
            --output text)
        #sleep 10
        echo "Public IP of $name is: $INSTANCE"
    fi
done
