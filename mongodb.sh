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
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo "${YELLOW}$2....${GREEN}SUCESS ${RESET}"
    else
        echo "${YELLOW}$2....${RED}FAILED ${RESET}"
        exit 1
    fi
}

if [ "$USER_ID" -eq 0 ]
then
    echo -e "${GREEN} SUCCESS:: YOUR ARE A ROOT USER SCRIPT CAN EXECUTION WILL START ${RESET}"
else 
    echo -e "${RED} ERROR:: YOUR NOT A ROOT USER PLEASE SWITCH TO ROOT USER ${RED}"
    exit 1
fi
echo "SCRIPT EXCEUTION STAT TIME :: $DATE"
echo -e "${YELLOW} MONGO-DB INSTALLATION SCRIPT STARTED TIME:: $DATE ${RESET}"
echo "-------------------------------------------------------------------------"
echo -e "{$YELLOW}SETTING-UP MONGO REPOSIOTORY FILE ${RESET}"
cp /home/centos/shell-scripting-Roboshop-Automation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "MONGO-REPO FILE COPYING"
echo "-------------------------------------------------------------------------"
echo
echo -e "${YELLOW}SCRIPT IS VERFYING MONGO-DB ALREADY INSTALLED IN LINUX SYSTEM (OR) NOT ? ${RESET}"
if which mongod &>>$LOG_FILE
then
    echo -e "${YEWLLO}MONGO-DB INSTALLED ALREADY SO ${GREEN} SKIPPING ${RESET} INSTALLATION PART"
else
    echo -e "${YELLOW} INSTALLING MONGO-DB ${RESET}"
    echo
    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? "MONGO-DB INSTALLATION"
fi
echo "---------------------------------------------------------------------------------"
echo
echo -e "${YELLOW}START AND ENABLE MONGO-DB ${RESET}"
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "MONGO-DB ENABLED"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "MONGO-DB STARTED"
echo "---------------------------------------------------------------------------------"
echo
echo -e "${YELLOW} Update listen address from 127.0.0.1 to 0.0.0.0 ${RESET}"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Updated listen address"
echo "---------------------------------------------------------------------------------"
echo
echo -e "${YELLOW}MONGO-DB RESTARTED ${RESET}"
netstat -tuln| grep '^tcp'| awk '{print $1, $4}'
VALIDATE "LISTENER UPDATION"
echo "SCRIPT EXECUTION DONE TIME:: $DATE"
echo "----------------${RED}THE-END ${RESET}--------------------------"





