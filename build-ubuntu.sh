#!/bin/bash

# Instructions:
# Run the two below commands on the pi.
# curl "https://raw.githubusercontent.com/bbaumg/scripts/master/build-ubuntu.sh" > build.sh && bash build.sh


#Variables
log="/var/log/firstboot.log"
v_repo='https://raw.githubusercontent.com/bbaumg/scripts/master'
v_defaultapps="logrotate vim wget htop" # ntsysv ntp traceroute lynx ftp sudoers curl mlocate"

# Base system configurations
echo "Setting to my timezone" | tee -a $log
timedatectl set-timezone America/Chicago | tee -a $log


#Set grub to show messages during boot
echo "Set machine to show messages during boot process" | tee -a $log
sed -i --follow-symlinks 's/rhgb\ //g' /etc/grub.conf

#Secure SSH
echo "Locking down SSH" | tee -a $log
sshconf="/etc/ssh/sshd_config"
sed -i --follow-symlinks 's/#PermitRootLogin\ yes/PermitRootLogin\ no/g' $sshconf
service sshd restart | tee -a $log

# Setup MOTD
#  This didn't work on Ubuntu 24.04
echo "Settup MOTD" | tee -a $log
curl "$v_repo/kickstart/motd.sh" > /etc/motd.sh
sed -i --follow-symlinks '/motd.sh/d' /etc/bashrc
echo '[ -n "$PS1" ] && bash /etc/motd.sh' >> /etc/bashrc

# Updating and Upgrading System to Latest
echo "Running apt update and then apt upgrade" | tee -a $log
apt update && apt upgrade -y | tee -a $log
echo "Installing default apps" | tee -a $log
bash <(echo "apt install -y $v_defaultapps") | tee -a $log

echo "Rebooting" | tee -a $log
reboot | tee -a $log
