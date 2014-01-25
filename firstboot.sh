#v_firstboot=/etc/firstboot.sh
#echo -n "#" > $v_firstboot
#echo -n ! >> $v_firstboot
#echo "/bin/bash" >> $v_firstboot
#echo "echo \"Starting the NIC\"" >> $v_firstboot
#echo "ifup eth0"  >> $v_firstboot
#echo "echo \"Installing wget\"" >> $v_firstboot
#echo "yum install -y wget" >> $v_firstboot
#echo "echo \"Downloading firstrun.sh\"" >> $v_firstboot
#echo "wget --output-document=/etc/firstrun.sh https://raw.github.com/bbaumg/scripts/master/firstrun.sh" >> $v_firstboot
#echo "bash /etc/firstrun.sh"  >> $v_firstboot
#cat /etc/firstboot.sh
#echo "bash /etc/firstboot.sh"  >> /etc/rc.local
#cat /etc/rc.local

rc='/etc/rc.local'
sed -i --follow-symlinks '/firstboot/d' $rc
sed -i --follow-symlinks '/firstrun/d' $rc
echo "curl -sL https://raw.github.com/bbaumg/scripts/master/firstrun.sh > /etc/firstrun.sh" >> $rc
echo "chmod 755 /etc/firstrun.sh" >> $rc
echo "bash /etc/firstrun.sh" >> $rc
#echo "bash <(curl -sL https://raw.github.com/bbaumg/scripts/master/firstrun.sh)" >> $rc

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
