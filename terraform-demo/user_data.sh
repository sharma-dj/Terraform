#!/bin/bash

HOME="/home/ubuntu"
logfile="$HOME/"terraform_log_"$(date +'%Y_%m')".txt
echo "script started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

# Install Apache
sudo apt-get -y install apache2
echo "Apache installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

# Start Apache
sudo systemctl start apache2
echo "Apache started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

# Enable Apache
sudo systemctl enable apache2
echo "Apache enabled at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

sudo apt-get update