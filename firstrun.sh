#!/bin/bash
#Variables
log="/var/log/firstboot.log"
admins='admins'
v_appinstall_url='https://raw.github.com/bbaumg/scripts/master/installs/install.sh'
v_defaultapps='logrotate bind-utils cifs-utils vim openssh-clients wget ntsysv ntp traceroute lynx ftp sudoers curl git'

# Verify it has not run before
if [ "$1" == "test" ]; then
	rm -f "$log"
	v_testing=1
fi
if [ -f "$log" ]; then exit 1; fi
source /etc/init.d/functions
clear

echo -en "Beginning base configuration...\n\n"
# Setup initial admin and groups
if [ "$v_testing" == 1 ]; then val_admin=1; fi
until [ "$val_admin" == 1 ]; do
	read -e -p "Enter the first admin's uername [ENTER]: " admin
	#Create user groups
	echo -e "\nAdding admins" | tee -a $log
	checkgroups=`grep "$admins" /etc/group | wc -l`
	if [ "$checkgroups" != 1 ]; then groupadd admins; fi
	useradd --groups "$admins" $admin
	checkadmin=`grep $admin /etc/passwd | wc -l`
	if [ "$checkadmin" == 1 ]; then
		val_admin=1
		echo -en "Admins group and default admin creation:"; success
	else
		echo -en "Admins group and default admin creation:"; failure
	fi
	echo
done

if [ "$v_testing" == 1 ]; then 
	echo
	passwd $admin
fi

until [ "$val_allgood" == "YES" ]; do
	val_ipaddr='0'
	val_netmask='0'
	val_gateway='0'
	# Collecting system information
	echo -en "\nEnter the hostname [ENTER]: "
	read v_hostname
	v_hostname=${v_hostname^^}
	#hostname $v_hostname
	until [ "$val_ipaddr" == 1 ]; do
	        read -e -p "Enter the IP address [ENTER]: " -i "$ipaddr" ipaddr
	        if [[ ! $ipaddr =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	                echo "That is not a valid address...  Please enter it again."
	        else
	       		echo -en "Determining if $ipaddr is already in use:"
			if ! /sbin/arping -q -c 2 -w 3 -D $ipaddr ; then
				failure
				echo -e "\nError, some other host already uses address $ipaddr.\n"
				val_ipaddr=0
			else
				success; echo
				val_ipaddr=1
			fi
	        fi
	done
	until [ "$val_netmask" == 1 ]; do
	        #echo -n "Enter the netmask [ENTER]: "
	        #read netmask
	        netmask='255.255.255.0'
	        if [[ ! $netmask =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	                echo "That is not a valid address...  Please enter it again."
	        else
	                val_netmask=1
	        fi
	done       
	until [ "$val_gateway" == 1 ]; do
	        #echo -n "Enter the gateway [ENTER]: "
	        if [ "$gateway" == '' ]; then 
			iparray=(`echo $ipaddr | tr "." " "`)
			gateway="${iparray[0]}.${iparray[1]}.${iparray[2]}.1"
	        fi
	        read -e -p "Enter the gateway [ENTER]: " -i "$gateway" gateway
	        if [[ ! $gateway =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	                echo "That is not a valid address...  Please enter it again."
	        else
	                val_gateway=1
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
	echo -en "\n\nPlease check the settings are right?\n\n"\
"Hostname=$v_hostname\n"\
"IPADDR=$ipaddr\n"\
"NETMASK=$netmask\n"\
"GATEWAY=$gateway\n"\
"$dns\n\n"
	read -e -p "Is everything Right [yes]: " val_allgood
	if [ "$val_allgood" == '' ]; then val_allgood='YES'; fi
done

# Install any apps?
bash <(curl -sL "$v_appinstall_url" ) 'firstboot'

# Set the Hostname
sed -c -i "s/\(HOSTNAME *= *\).*/\HOSTNAME=$v_hostname/" /etc/sysconfig/network

#Enable eth0
#ifup eth0  #This should no longer be needed.

#Set grub to show messages during boot
echo "Set machine to show messages during boot process" | tee -a $log
sed -i --follow-symlinks 's/rhgb\ //g' /etc/grub.conf

#Disable SELINUX
echo "Disabling SELINUX" | tee -a $log
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#Secure SSH
echo "Locking down SSH" | tee -a $log
sshconf="/etc/ssh/sshd_config"
sed -i --follow-symlinks 's/#PermitRootLogin\ yes/PermitRootLogin\ no/g' $sshconf
sed -i --follow-symlinks 's/#Banner\ none/Banner\ \/etc\/issue/g' $sshconf
sed -i --follow-symlinks 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' $sshconf
service sshd restart | tee -a $log

#Configure IP Tables
echo "Configuring iptables" | tee -a $log
ipt="/etc/sysconfig/iptables"
echo "*filter" > $ipt
echo ":INPUT DROP [0:0]" >> $ipt
echo ":FORWARD DROP [0:0]" >> $ipt
echo ":OUTPUT ACCEPT [0:0]" >> $ipt
echo "-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" >> $ipt
echo "-A INPUT -p icmp -j ACCEPT" >> $ipt
echo "-A INPUT -i lo -j ACCEPT" >> $ipt
echo "-A INPUT -m tcp -p tcp --dport 7 -j ACCEPT" >> $ipt
echo "-A INPUT -s ${iparray[0]}.${iparray[1]}.${iparray[2]}.0/24 -m state --state NEW -p tcp --dport 22 -j ACCEPT" >> $ipt
echo "" >> $ipt
echo "#SNMP" >> $ipt
echo "-A INPUT -p udp --dport 161 -j ACCEPT" >> $ipt
echo "-A INPUT -p udp --dport 123 -j ACCEPT" >> $ipt
echo "" >> $ipt
echo "COMMIT" >> $ipt
service iptables restart | tee -a $log

#Configure Sudoers
echo "Configuring sudoers" | tee -a $log
echo "%admins       ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# Setup MOTD to run at login
echo "Settup MOTD" | tee -a $log
sed -i --follow-symlinks '/motd.sh/d' /etc/bashrc
echo '[ -n "$PS1" ] && bash /etc/motd.sh' >> /etc/bashrc

#Update, upgrade, and install apps
echo "YUM update" | tee -a $log
yum update -y | tee -a $log
echo "YUM upgrade" | tee -a $log
yum upgrade -y | tee -a $log
echo "Install apps" | tee -a $log
yum install -y "$v_defaultapps" | tee -a $log
echo "Cleanup installs" | tee -a $log
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
reboot
