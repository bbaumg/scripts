#!/bin/bash

# Variables/Constants

# Set the rc.local file to clean anything from past builds and set the firstrun scripts.
rc='/etc/rc.local'
sed -i --follow-symlinks '/firstboot/d' $rc
sed -i --follow-symlinks '/firstrun/d' $rc
echo "curl -s https://raw.githubusercontent.com/bbaumg/scripts/master/kickstart/firstrun.sh > /etc/firstrun.sh" >> $rc
echo "chmod 755 /etc/firstrun.sh" >> $rc
echo "bash /etc/firstrun.sh" >> $rc

# Configure the NIC card for a general DHCP initial boot
entname=$(ip addr | awk -F ": " '!/  /{print $2}' | grep --invert-match 'lo')
eth0='/etc/sysconfig/network-scripts/ifcfg-'$entname
echo -e "DEVICE=$entname\n"\
"TYPE=Ethernet\n"\
"ONBOOT=yes\n"\
"NM_CONTROLLED=yes\n"\
"BOOTPROTO=dhcp" > $eth0

# If RHEL 6 Adjust rc.sysinit so sys-unconfig does not prompt for auth type
OSVer=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | awk -F '.' '{print $1}')
if [ $OSVer -eq '6' ]; then
  sed -i --follow-symlinks 's/authconfig-tui\ --nostart/authconfig-tui\ --nostart\ --kickstart/g' /etc/rc.sysinit
fi


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
history -c
sys-unconfig
