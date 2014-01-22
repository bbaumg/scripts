#!/bin/bash
#Variables
log="/var/log/firstboot.log"
if [ -f "$log" ]; then
        exit 1
fi

# Setting up the first Admin
#echo "Set a new root password"
#passwd
echo -n "Enter the first admin uername [ENTER]: "
read admin
#Create user groups
echo "Adding admins" | tee -a $log
groupadd admins
useradd --groups admins $admin
echo "Enter the first admin’s password:"
passwd $admin

# Collecting system information
echo -n "Enter the hostname [ENTER]: "
read v_hostname
#hostname $v_hostname
echo -n "Enter the IP address [ENTER]: "
read ipaddr
#echo -n "Enter the subnet mask [ENTER]: "
#read netmask
netmask="255.255.255.0"
echo -n "Enter the gateway [ENTER]: "
read gateway
#echo -n "Enter the DNS [ENTER]: "
#read dns
dns="8.8.8.8"

# Install any apps?
bash <(curl -srL 'https://raw.github.com/bbaumg/scripts/master/installs/install.sh') 'firstboot'

# Set the Hostname
sed -c -i "s/\(HOSTNAME *= *\).*/\HOSTNAME=$v_hostname/" /etc/sysconfig/network

#Enable eth0
#ifup eth0  #This should no longer be needed.

#Disable SELINUX
echo "Disabling SELINUX" | tee -a $log
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#Secure SSH
sshconf="/etc/ssh/sshd_config"
sed -i 's/#PermitRootLogin\ yes/PermitRootLogin\ no/g' $sshconf
sed -i 's/#Banner\ none/Banner\ \/etc\/issue/g' $sshconf
sed -i 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' $sshconf
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
mac=$(cat /sys/class/net/eth0/address)
echo "Configuring the NIC:" | tee -a $log
echo "DEVICE=eth0" > $eth0
echo "TYPE=Ethernet" >> $eth0
echo "ONBOOT=yes" >> $eth0
echo "NM_CONTROLLED=yes" >> $eth0
echo "HWADDR=$mac" >> $eth0
echo "BOOTPROTO=none" >> $eth0
echo "IPADDR=$ipaddr" >> $eth0
echo "NETMASK=$netmask" >> $eth0
echo "GATEWAY=$gateway" >> $eth0
echo "DNS=$dns" >> $eth0
service network restart

#Cleanup and reboot
#awk '!/firstboot/' /etc/rc.local > /etc/rc.local.tmp && mv -f /etc/rc.local.tmp /etc/rc.local
sed -i --follow-symlinks '/firstboot/d' /etc/rc.local
sed -i --follow-symlinks '/firstrun/d' /etc/rc.local
shutdown -r now
