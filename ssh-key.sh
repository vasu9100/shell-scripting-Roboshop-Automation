#!/bin/bash
#!/bin/bash
# Script Name: install_mongodb.sh
# Purpose: This script installs MongoDB for the Roboshop application.
# Author: Gonepudi Srinivas
# Date: March 18, 2024
# Version: 1.0

# Define colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PINK='\033[1;35m'
RESET='\033[0m'

# Log file setup
DATE=$(date +'%F-%H-%M-%S')
USER_ID=$(id -u)
echo
VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}SUCCESS: $2${RESET}"
    else
        echo -e "${RED}FAILED: $2${RESET}"
        exit 1
    fi
}
echo
TASK_STARTED(){
    echo "<--------------------------------------------------------------->"
    echo -e "${PINK}TASK_STARTED--> $1 ${RESET}\n"
    echo "<--------------------------------------------------------------->"

}
echo
if [ "$USER_ID" -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: You are a root user. Script execution will start.${RESET}\n"
else 
    echo -e "${RED}ERROR: You are not a root user. Please switch to the root user.${RESET}\n"
    exit 1
fi
echo
TASK_STARTED "SSH KEY CREATION STARTED"
if [ -f "/home/centos/id_rsa.pub" ]
then
    echo -e "${RED}SSH PUBLIC KEY ALREADY EXISTED SO THIS $0 SCRIPT STOPPED CREATING NEW KEY"
else
    echo -e "${GREEN}SSH KEY IS NOT THERE SO THIS $0 SCRIPT STARTED CREATING NEW KEY ${RESET}"
    echo
    ssh-keygen -t rsa -b 4096 -f /home/centos/id_rsa
    VALIDATE $? "SSH KEY GENERATION"
fi
TASK_STARTED "PUBLIC-IP GATHERING"
PUBLIC_IP=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)

for i in "${PUBLIC_IP[@]}"; do
    echo -e "${GREEN}TRYING TO LOGIN TO EC2 INSTANCES${RESET}/n"
    sshpass -p DevOps321 ssh -i centos@${PUBLIC_IP}
    VALIDATE $? "Logged into ${PUBLIC_IP}"
    ssh-copy-id -i /home/centos/id_rsa.pub centos@${PUBLIC_IP}
done    


