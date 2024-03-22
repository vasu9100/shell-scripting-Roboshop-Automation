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
echo -e "${YELLOW}SCRIPT RPM STARTED DOWNLOADING"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOG_FILE
VALIDATE $? "SCRIPT RPM INSTALLATION"
echo "----------------------------------------------------------------------------------------"
echo
echo -e "$YELLOW}Configure YUM Repos for RabbitMQ."
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOG_FILE
VALIDATE $? "YUM REPO FOR RABBIT SETUP"
echo "-----------------------------------------------------------------------------------------"
echo -e "${YELLOW}RABBIT-MQ INSTALLATION START"
rpm -qa | grep rabbitmq-server
if [ $? -eq 0 ]
then
    echo "RABBIT-MQ ALREADY INSTALLED SO SKIPPING THIS PART"
else
    echo -e "RABBIT-MQ IS NOT EXISTED SO INSTALLAING"
    dnf install rabbitmq-server -y 
    VALIDATE $? "RABBIT-MQ INSTALLATION" 
fi
echo "-------------------------------------------------------------------------------------------"       
echo
systemctl enable rabbitmq-server
VALIDATE $? "RABBIT-MQ ENABLED"
systemctl start rabbitmq-server
VALIDATE $? "RABBIT-MQ STARTED"
echo "--------------------------------------------------------------------------------------------"
echorabbitmqctl add_user roboshop roboshop123
VALIDATE $? "ROBOSHOP USERS ADDED"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "PERMISSIONS SETUP"
echo "--------------------------------THE-END--------------------------------------------------------"
echo -e  "${YELLOW}SCRIPT EXCEUTION DONE TIME : $DATE"
