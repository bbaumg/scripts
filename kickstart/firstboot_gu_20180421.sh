#!/bin/bash

####################################################################################################
#	Preparation script to create a new base template server
#
#	TODO:
#		- Make the script automatically run upon first boot in version 7
#			https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/s1-one-time_script_on_next_boot_using_systemd_unit_file.html
#			https://alan-mushi.github.io/2014/10/26/execute-an-interactive-script-at-boot-with-systemd.html
#			Will require adding functionality to checking for OS version and having different processes for init.d vs systemd startup scripts
####################################################################################################


# Variables/Constants
OSVer=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | awk -F '.' '{print $1}')
OSFlavor=$(cat /etc/redhat-release | awk '{print $1}')

# Set the rc.local file to clean anything from past builds and set the firstrun scripts.
rc='/etc/rc.local'
sed -i --follow-symlinks '/firstboot/d' $rc
sed -i --follow-symlinks '/firstrun/d' $rc
echo "curl -k https://raw.githubusercontent.com/bbaumg/scripts/master/kickstart/firstrun_gu_20180421.sh > /etc/firstrun.sh" >> $rc
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
if [ $OSVer -eq '6' ]; then
  sed -i --follow-symlinks 's/authconfig-tui\ --nostart/authconfig-tui\ --nostart\ --kickstart/g' /etc/rc.sysinit
fi

# Bring the machine up to date before sealing.

case "$OSFlavor" in
        Red)
                # Register RHEL YUM
                echo "Registering with RHEL package manager.  Anything other than RHEL will Error" | tee -a $log
                echo -en "What is the Red Hat Password:  "
                read -s rhelpw
				echo -e "Thank you...  Registering..."
				subscription-manager register --username netalerts@grantham.edu --password $rhelpw --auto-attach | tee -a $log
				echo -e "Installing updates"
				yum upgrade -y
				subscription-manager unregister
                ;;
        CentOS)
                echo "This is a CentOS machine, no need to register with RHEL package manager" | tee -a $log
				echo -e "Installing updates"
				yum upgrade -y
                ;;
        *)
                echo "That is weird...  What OS are you running... It is not RHEL/CENTOS"  | tee -a $log
                ;;
esac



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
