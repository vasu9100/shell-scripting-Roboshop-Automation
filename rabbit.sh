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
PINK='\033[0;35m'   # Pink color added
RESET='\033[0m'
DATE=$(date +'%F-%H-%M-%S')
USER_ID=$(id -u)
LOG_FILE="/tmp/$0-$DATE.log"

# Function to validate commands
VALIDATE() {
    if [ "$1" -eq 0 ]; then
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
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}\n"
    exit 1
fi

TASK_STARTED "Downloading Script RPM"
echo -e "${YELLOW}SCRIPT RPM STARTED DOWNLOADING${RESET}\n"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOG_FILE
VALIDATE $? "SCRIPT RPM INSTALLATION"

TASK_STARTED "Configuring YUM Repos for RabbitMQ"
echo -e "${YELLOW}Configure YUM Repos for RabbitMQ.${RESET}\n"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOG_FILE
VALIDATE $? "YUM REPO FOR RABBIT SETUP"

TASK_STARTED "Installing RabbitMQ"
echo -e "${YELLOW}RABBIT-MQ INSTALLATION START${RESET}\n"
rpm -qa | grep rabbitmq-server
if [ $? -eq 0 ]; then
    echo -e "RABBIT-MQ ALREADY INSTALLED. SKIPPING THIS PART\n"
else
    echo -e "${YELLOW}RABBIT-MQ IS NOT EXISTED SO INSTALLING${RESET}\n"
    dnf install rabbitmq-server -y &>>$LOG_FILE 
    VALIDATE $? "RABBIT-MQ INSTALLATION"
fi

echo -e "-------------------------------------------------------------------------------------------\n"       

echo -e "${YELLOW}Enabling RabbitMQ Service${RESET}\n"
systemctl enable rabbitmq-server
VALIDATE $? "RABBIT-MQ ENABLED"

echo -e "${YELLOW}Starting RabbitMQ Service${RESET}\n"
systemctl start rabbitmq-server
VALIDATE $? "RABBIT-MQ STARTED"

echo -e "--------------------------------------------------------------------------------------------\n"

rabbitmqctl list_users | grep roboshop &>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "${YELLOW}Roboshop users already exists.${RESET} Skipping user creation."
else
    echo -e "${YELLOW}Creating Roboshop user...${RESET}"
    rabbitmqctl add_user roboshop roboshop123
    VALIDATE $? "Roboshop User Creation"
fi

echo -e "${YELLOW}Setting Permissions${RESET}\n"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "PERMISSIONS SETUP"
echo -e "${YELLOW}SCRIPT EXECUTION DONE TIME: $DATE${RESET}\n"
echo -e "--------------------------------THE-END--------------------------------------------------------\n"

