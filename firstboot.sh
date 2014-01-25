#!/bin/bash

# Variables/Constants

# Set the rc.local file to clean anything from past builds and set the firstrun scripts.
rc='/etc/rc.local'
sed -i --follow-symlinks '/firstboot/d' $rc
sed -i --follow-symlinks '/firstrun/d' $rc
echo "curl -sL https://raw.github.com/bbaumg/scripts/master/firstrun.sh > /etc/firstrun.sh" >> $rc
echo "chmod 755 /etc/firstrun.sh" >> $rc
echo "bash /etc/firstrun.sh | tee /var/log/firstboot.log" >> $rc

# Configure the NIC card for a general DHCP initial boot
eth0="/etc/sysconfig/network-scripts/ifcfg-eth0"
echo -e "DEVICE=eth0\n"\
"TYPE=Ethernet\n"\
"ONBOOT=yes\n"\
"NM_CONTROLLED=yes\n"\
"BOOTPROTO=dhcp" > $eth0

# Adjust rc.sysinit so sys-unconfig does not prompt for auth type
sed -i --follow-symlinks 's/authconfig-tui\ --nostart/authconfig-tui\ --nostart\ --kickstart/g' /etc/rc.sysinit

rm -f /var/log/firstboot.log
logrotate -f /etc/logrotate.conf
cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -f ~root/.bash_history
rm -f /etc/ssh/*key*
rm -rf /etc/ssh/ssh_host_*
rm -rf /etc/udev/rules.d/70-*
sleep 3
unset HISTFILE
sys-unconfig
