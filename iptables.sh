#!/bin/bash

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
echo "-A INPUT -i eth0 -s  240.0.0.0/4  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "-A INPUT -i eth0 -s  255.255.255.255/32  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "-A INPUT -i eth0 -s 168.254.0.0/16  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "-A INPUT -i eth0 -s 248.0.0.0/5  -j LOG --log-prefix \"IP DROP \"" >> $ipt
echo "COMMIT" >> $ipt
service iptables restart
