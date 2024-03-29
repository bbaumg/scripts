#!/bin/bash

# Instructions:
# Run the two below commands on the pi.
# curl "https://raw.githubusercontent.com/bbaumg/scripts/master/pi/build.sh" > build.sh && bash build.sh

# Exit if you ran this as root...
if [ "$(whoami)" == "root" ]; then
        echo "Don't run as sudo/root"
        echo "bash build.sh"
        exit 1
fi
#Variables
log="/var/log/pibuild.log"
sudo touch $log
sudo chmod 666 $log
v_repo='https://raw.githubusercontent.com/bbaumg/scripts/master'
v_defaultapps="vim git htop i2c-tools python3-dev python3-venv python3-smbus"
#v_defaultapps="vim git-core git htop python python-pip python-dev python-smbus python-imaging i2c-tools"
#v_defaultapps="python3-pip python3-dev python3-venv python3-smbus vim git-core locate build-essential scons swig htop"
v_gitEmail=''
v_gitUser=''

while true; do
    read -p "Do you wish to schedule auto-updates (y/n)? " yn
    case $yn in
        [Yy]* )
                echo "Updates will be scheduled weekly."
                var_Upgrade='Y'
                break;;
        [Nn]* )
                echo "You will do your own updates."
                var_Upgrade='N'
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
yn=''
while true; do
    read -p "Do you wish to configure GIT (y/n)? " yn
    case $yn in
        [Yy]* )
                echo -e "The next couple questions are to collect info configuring GIT:"
                var_git='Y'
                read -p "What is your email address: " v_gitEmail
                read -p "What is your username: " v_gitUser
                break;;
        [Nn]* )
                echo "no more questions"
                var_git='N'
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Do you want to setup wireless (y/n)? " yn
    case $yn in
        [Yy]* )
            read -p "What SSID do you want to connect to? " wifiSSID
            #echo -en "\n$wifiSSID\n"
            echo -en "What is the Password? "
            read -s wifiPass
            echo -en "\nCreating wifi settings file 'wpa_supplicant.conf'\n"
            #echo -en "\n$wifiPass\n"
            echo -en "country=US\n"\
"ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n"\
"network={\n\tssid=\"$wifiSSID\"\n\tpsk=\"$wifiPass\"\n\tkey_mgmt=WPA-PSK\n}\n" > wpa_supplicant.conf
            break;;
        [Nn]* )
                echo "OK...  No Wireless"
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Change the password
# echo "Change your password" | tee -a $log
# passwd

read -p "What do you want to name this PI? " var_name
echo -en "\nThis Pi will be named $var_name\n\n" | tee -a $log

# OK, let's install all of the basic stuff and do the basline configurations
echo -en "\n-------------------------------------------------------\napt-get update\n\n" | tee -a $log
sudo apt-get update -y | tee -a $log
echo -en "\n-------------------------------------------------------\napt-get upgrade\n\n" | tee -a $log
sudo apt-get upgrade -y | tee -a $log
echo -en "\n-------------------------------------------------------\napt-get dist-upgrade\n\n" | tee -a $log
sudo apt-get dist-upgrade -y | tee -a $log
echo -en "\n-------------------------------------------------------\napt-get autoremove\n\n" | tee -a $log
sudo apt-get autoremove -y | tee -a $log
echo -en "\n-------------------------------------------------------\napt-get clean\n\n" | tee -a $log
sudo apt-get clean -y | tee -a $log
echo -en "\n-------------------------------------------------------\napt-get update\n\n" | tee -a $log
sudo apt-get update -y | tee -a $log
echo -en "\n-------------------------------------------------------\napt-get install\n\n" | tee -a $log
sudo apt-get install -y $v_defaultapps | tee -a $log

echo -en "\n-------------------------------------------------------\nAdding to .bashrc\n\n" | tee -a $log
sed -i --follow-symlinks '/stuff/d' .bashrc
sed -i --follow-symlinks '/alias ll/d' .bashrc
sed -i --follow-symlinks '/export EDITOR/d' .bashrc
sed -i --follow-symlinks '/alias python/d' .bashrc
echo -en "\n# Some stuff I added\n"\
"alias ll='ls -alh'\n"\
"export EDITOR=vim\n" >> .bashrc

echo -en "\n-------------------------------------------------------\nCreating .vimrc\n\n" | tee -a $log
echo "set mouse-=a" > .vimrc

if [ $var_Upgrade = "Y" ]; then
  echo -en "\n-------------------------------------------------------\nCreating root crontab\n\n" | tee -a $log
  echo -en ""\
  "0 2 * * 1 apt-get update -y && apt-get dist-upgrade -y\n" > rootcrontab
  #sudo crontab rootcrontab
fi

echo -en "\n-------------------------------------------------------\nSettup MOTD\n\n" | tee -a $log
curl "$v_repo/kickstart/banner" | sudo tee /etc/issue
curl "$v_repo/kickstart/motd.sh" | sudo tee /etc/motd.sh
sed -i --follow-symlinks '/motd.sh/d' .bashrc
echo '[ -n "$PS1" ] && bash /etc/motd.sh' >> .bashrc

#echo -en "\n-------------------------------------------------------\nLocking down SSH\n\n" | tee -a $log
#echo "Locking down SSH" | tee -a $log
#sshconf="/etc/ssh/sshd_config"
#sudo sed -i --follow-symlinks 's/#PermitRootLogin\ yes/PermitRootLogin\ no/g' $sshconf
#sed -i --follow-symlinks 's/#PrintLastLog\ yes/PrintLastLog\ no/g' $sshconf
#sed -i --follow-symlinks 's/#Banner\ none/Banner\ \/etc\/issue/g' $sshconf
#sed -i --follow-symlinks 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' $sshconf
#sudo service sshd restart | tee -a $log




###  Some SED examples for future use:
#sed -ir 's/^expose_php.*$/expose_php = Off/g' /etc/php.ini | tee -a $log
#sed -ir 's/^file_uploads.*$/file_uploads = On/g' /etc/php.ini | tee -a $log
#sed -ir 's/^allow_url_fopen.*$/allow_url_fopen = Off/g' /etc/php.ini | tee -a $log
#sed -ir 's/^allow_url_fopen.*$/allow_url_fopen = Off/g' /etc/php.ini | tee -a $log
#sed -ir '/date\.timezone =.*/s/.*/date\.timezone = "America\/Chicado"/g' /etc/php.ini | tee -a $log
#sed -ir 's/file_uploads.*$/file_uploads = Off/g' /etc/php.ini | tee -a $log
#sed -ir 's/sql.safe_mode.*$/sql.safe_mode = Off/g' /etc/php.ini
# The following were not in the current php.ini file.  not sure if they should be added or not...
#sed -ir 's/safe_mode.*$/safe_mode = On/g' /etc/php.ini
#sed -ir 's/safe_mode_include_dir.*$/safe_mode_include_dir = \/var\/www\/html/g' /etc/php.ini



if [ $var_Git = "Y" ]; then
  echo -en "\n-------------------------------------------------------\nSetting up git\n\n" | tee -a $log
  cd $HOME
  git config --global user.email "$v_gitEmail"
  git config --global user.name "$v_gitUser"
  git config --global credential.helper store
fi

echo -en "\n-------------------------------------------------------\nRunning raspi-config commands\n\n" | tee -a $log
sudo raspi-config nonint do_hostname $var_name
sudo raspi-config nonint do_expand_rootfs
sudo raspi-config nonint do_change_locale en_US.UTF-8
sudo raspi-config nonint do_change_timezone US/Central
#sudo raspi-config

echo -en "\n-------------------------------------------------------\nBuild Complete\n\n" | tee -a $log

echo -en "\n\n\nSetup SSK Keys 'ssh-copy-id remote_username@server_ip_address'\n\n" | tee -a $log
while true; do
    read -p "Reboot now (y/n)? " yn
    case $yn in
        [Yy]* )
                sudo reboot
                break;;
        [Nn]* )
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
