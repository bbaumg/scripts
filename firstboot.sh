v_firstboot=/etc/firstboot.sh
echo -n "#" > $v_firstboot
echo -n ! >> $v_firstboot
echo "/bin/bash" >> $v_firstboot
echo "echo \"Starting the NIC\"" >> $v_firstboot
echo "ifup eth0"  >> $v_firstboot
echo "echo \"Installing wget\"" >> $v_firstboot
echo "yum install -y wget" >> $v_firstboot
echo "echo \"Downloading firstrun.sh\"" >> $v_firstboot
echo "wget --output-document=/etc/firstrun.sh https://raw.github.com/bbaumg/scripts/master/firstrun.sh" >> $v_firstboot
echo "bash /etc/firstrun.sh"  >> $v_firstboot
cat /etc/firstboot.sh
Configure the NIC card
#rc='/etc/rc.local'
#echo "curl -sL https://raw.github.com/bbaumg/scripts/master/firstrun.sh > /etc/firstrun.sh" >> $rc
#echo "chmod 755 /etc/firstrun.sh" >> $rc
#echo "/etc/firstrun.sh" >> $rc

#echo "bash <(curl -sL https://raw.github.com/bbaumg/scripts/master/firstrun.sh)" >> $rc

eth0="/etc/sysconfig/network-scripts/ifcfg-eth0"
echo -e "DEVICE=eth0\n"\
"TYPE=Ethernet\n"\
"ONBOOT=yes\n"\
"NM_CONTROLLED=yes\n"\
"BOOTPROTO=dhcp" > $eth0
logrotate -f /etc/logrotate.conf
cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -f ~root/.bash_history
rm -f /etc/ssh/*key*
rm -rf /etc/ssh/ssh_host_*
rm -rf /etc/udev/rules.d/70-*
echo "bash /etc/firstboot.sh"  >> /etc/rc.local
#cat /etc/rc.local
unset HISTFILE
#sys-unconfig
#poweroff
