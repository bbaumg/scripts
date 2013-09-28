#!/bin/bash
#Variables
log="/var/log/firstboot.log"

# Start the NIC
echo "Starting the NIC" | tee -a $log
ifup eth0
# Install wget - needed to download most current firstrun.sh script
echo "Installing wget" | tee -a $log
yum install -y wget

# Download the most current firstrun.sh script
echo "Downloading firstrun.sh" | tee -a $log
wget --output-document=/etc/firstrun.sh https://raw.github.com/bbaumg/scripts/edit/master/firstrun.sh

# Start firstrun.sh
bash /etc/firstrun.sh
