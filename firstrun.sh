#!/bin/bash
#Variables
log="/var/log/firstboot.log"

# Verify it has not run before
if [ -f "$log" ]; then exit 1; fi
source /etc/init.d/functions
clear

echo -en "Beginning base configuration...\n\n"
# Setup initial admin and groups
until [ $val_admin ]; do
	echo -en "Enter the first admin's uername [ENTER]: "
	read admin
	#Create user groups
	echo "Adding admins" | tee -a $log
	groupadd admins
	useradd --groups admins $admin
	checkadmin=`grep $admin /etc/passwd | wc -l`
	if [ "$checkadmin" == 1 ]; then
		val_admin=true
		echo -en "Admins group and default admin creation:"; success
	else
		echo -en "Admins group and default admin creation:"; failure
	fi
done

#echo -en "\nEnter the first admin’s password:"
echo
passwd $admin

# Collecting system information
echo -en "\nEnter the hostname [ENTER]: "
read v_hostname
v_hostname=${v_hostname^^}
#hostname $v_hostname
until [ $val_ipaddr ]; do
        echo -n "Enter the IP address [ENTER]: "
        read ipaddr
        if [[ ! $ipaddr =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "That is not a valid address...  Please enter it again."
        else
                val_ipaddr=true
        fi
done
until [ $val_netmask ]; do
        #echo -n "Enter the netmask [ENTER]: "
        #read netmask
        netmask='255.255.255.0'
        if [[ ! $netmask =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "That is not a valid address...  Please enter it again."
        else
                val_netmask=true
        fi
done       
until [ $val_gateway ]; do
        echo -n "Enter the gateway [ENTER]: "
        read gateway
        if [[ ! $gateway =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "That is not a valid address...  Please enter it again."
        else
                val_gateway=true
        fi
done
echo -en "On net or Off [0=Off, 1=On]: "
read onnet
if [ "$onnet" = "1" ]; then
        dns="DNS1=172.16.121.19\nDNS2=172.16.121.41\nDNS3=172.16.0.57\nDNS4=172.16.1.40"
else
        dns="DNS1=8.8.8.8\nDNS2=8.8.4.4"    
fi
#echo -n "Enter the DNS [ENTER]: "

# Install any apps?
bash <(curl -srL 'https://raw.github.com/bbaumg/scripts/master/installs/install.sh') 'firstboot'

# Set the Hostname
sed -c -i "s/\(HOSTNAME *= *\).*/\HOSTNAME=$v_hostname/" /etc/sysconfig/network

#Enable eth0
#ifup eth0  #This should no longer be needed.

#Set grub to show messages during boot
sed -i --follow-symlinks 's/rhgb\ //g' /etc/grub.conf

#Disable SELINUX
echo "Disabling SELINUX" | tee -a $log
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#Secure SSH
sshconf="/etc/ssh/sshd_config"
sed -i --follow-symlinks 's/#PermitRootLogin\ yes/PermitRootLogin\ no/g' $sshconf
sed -i --follow-symlinks 's/#Banner\ none/Banner\ \/etc\/issue/g' $sshconf
sed -i --follow-symlinks 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' $sshconf
service sshd restart

#Configure IP Tables
ipt="/etc/sysconfig/iptables"
echo "*filter" > $ipt
echo ":INPUT DROP [0:0]" >> $ipt
echo ":FORWARD DROP [0:0]" >> $ipt
echo ":OUTPUT ACCEPT [0:0]" >> $ipt
echo "-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" >> $ipt
echo "-A INPUT -p icmp -j ACCEPT" >> $ipt
echo "-A INPUT -i lo -j ACCEPT" >> $ipt
echo "-A INPUT -m tcp -p tcp --dport 7 -j ACCEPT" >> $ipt
echo "#-A INPUT -s 172.16.0.0/16 -m state --state NEW -p tcp --dport 22 -j ACCEPT" >> $ipt
echo "#-A INPUT -s 172.16.0.0/16 -m state --state NEW -p tcp --dport 1621 -j ACCEPT" >> $ipt
echo "#-A INPUT -s 172.16.0.0/16 -m state --state NEW -p tcp --dport 1521 -j ACCEPT" >> $ipt
echo "# Example SSH Access" >> $ipt
echo "#-A INPUT -s 69.196.253.30/32 -m state --state NEW -p tcp --dport 22 -j ACCEPT" >> $ipt
echo "#-A INPUT -s 67.53.65.246/32 -m state --state NEW -p tcp --dport 22 -j ACCEPT" >> $ipt
echo "-A INPUT -s 10.15.81.0/24 -m state --state NEW -p tcp --dport 22 -j ACCEPT" >> $ipt
echo "" >> $ipt
echo "#SNMP" >> $ipt
echo "-A INPUT -p udp --dport 161 -j ACCEPT" >> $ipt
echo "-A INPUT -p udp --dport 123 -j ACCEPT" >> $ipt
echo "" >> $ipt
echo "#Base logging rules" >> $ipt
echo "-A INPUT -j REJECT --reject-with icmp-host-prohibited" >> $ipt
echo "-A INPUT -i eth0 -s 10.0.0.0/8 -j LOG --log-prefix \"IP DROP SPOOF \"" >> $ipt
echo "-A INPUT -i eth0 -s 172.16.0.0/12 -j LOG --log-prefix \"IP DROP SPOOF \"" >> $ipt
echo "-A INPUT -i eth0 -s 192.168.0.0/16 -j LOG --log-prefix \"IP DROP SPOOF \"" >> $ipt
echo "-A INPUT -i eth0 -s 224.0.0.0/4 -j LOG --log-prefix \"IP DROP MULTICAST \"" >> $ipt
echo "-A INPUT -i eth0 -s 240.0.0.0/5 -j LOG --log-prefix \"IP DROP SPOOF \"" >> $ipt
echo "-A INPUT -i eth0 -d 127.0.0.0/8 -j LOG --log-prefix \"IP DROP LOOPBACK \"" >> $ipt
echo "-A INPUT -i eth0 -s 169.254.0.0/16  -j LOG --log-prefix \"IP DROP MULTICAST \"" >> $ipt
echo "-A INPUT -i eth0 -s 0.0.0.0/8  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "-A INPUT -i eth0 -s 240.0.0.0/4  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "-A INPUT -i eth0 -s 255.255.255.255/32  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "-A INPUT -i eth0 -s 168.254.0.0/16  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "-A INPUT -i eth0 -s 248.0.0.0/5  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "COMMIT" >> $ipt
service iptables restart

#Configure Sudoers
echo "Configuring sudoers" | tee -a $log
echo "%admins       ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# Setup MOTD to run at login
echo '[ -n "$PS1" ] && bash /etc/motd.sh' >> /etc/bashrc

#Update, upgrade, and install apps
echo "YUM update" | tee -a $log
yum update -y | tee -a $log
echo "YUM upgrade" | tee -a $log
yum upgrade -y | tee -a $log
echo "Install apps" | tee -a $log
yum install -y logrotate bind-utils cifs-utils vim openssh-clients wget ntsysv ntp traceroute lynx ftp sudoers curl git | tee -a $log
echo "cleanup installs" | tee -a $log
yum clean all | tee -a $log

# Install custom apps
#curl -L $v_app_1 | bash 2>&1 | tee 

#Install the MCP
v_mpc="/var/scripts/mcp.sh"
mkdir /var/scripts
echo '#!/bin/bash' > $v_mpc
echo 'echo "Starting MCP (Minion Control Program)"' >> $v_mpc
echo 'echo "Getting the most up to date minion.sh"' >> $v_mpc
echo 'wget --output-document=/var/scripts/minion.sh https://raw.github.com/bbaumg/scripts/master/minion/minion.sh' >> $v_mpc
echo 'echo "Run MCP"' >> $v_mpc
echo 'bash /var/scripts/minion.sh 2>&1 | tee -a /var/log/minion.log' >> $v_mpc
bash /var/scripts/mcp.sh

#Configure the NIC card
eth0="/etc/sysconfig/network-scripts/ifcfg-eth0"
if [ ! -f "$eth0" ]; then
        echo "Making a backup of '$eth0'" | tee -a $log
        cp -f $eth0 $eth0.backup
fi
rm -rf /etc/udev/rules.d/70-*
echo "Configuring the NIC:" | tee -a $log
mac=$(cat /sys/class/net/eth0/address)
echo -en "DEVICE=eth0\n"\
"TYPE=Ethernet\n"\
"ONBOOT=yes\n"\
"NM_CONTROLLED=yes\n"\
"HWADDR=$mac\n"\
"BOOTPROTO=none\n"\
"IPADDR=$ipaddr\n"\
"NETMASK=$netmask\n"\
"GATEWAY=$gateway\n"\
"$dns" > $eth0
service network restart

#Cleanup and reboot
#awk '!/firstboot/' /etc/rc.local > /etc/rc.local.tmp && mv -f /etc/rc.local.tmp /etc/rc.local
sed -i --follow-symlinks '/firstboot/d' /etc/rc.local
sed -i --follow-symlinks '/firstrun/d' /etc/rc.local
shutdown -r now
