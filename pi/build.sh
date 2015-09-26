#!/bin/bash

#Variables
v_repo='https://raw.githubusercontent.com/bbaumg/scripts/master'

#curl "https://raw.githubusercontent.com/bbaumg/scripts/master/pi/build.sh" > build.sh
#sudo bash build.sh

sudo raspi-config
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y python3-pip python3-dev vim git-core locate build-essential scons swig
sudo pip-3.2 install pyephem pymysql configparser
echo -en "\n-------------------------------------------------------\nAdding to .bashrc\n\n"
echo -en "\n# Some stuff I added\n"\
"alias ll='ls -alh'\n"\
"export EDITOR=vim\n"
"alias python=python3\n" >> .bashrc
echo -en "\n-------------------------------------------------------\nCreating root crontab\n\n"
echo -en ""\
"# Edit this file to introduce tasks to be run by cron.\n"\
"# \n"\
"# Each task to run has to be defined through a single line\n"\
"# indicating with different fields when the task will be run\n"\
"# and what command to run for the task\n"\
"# \n"\
"# To define the time you can provide concrete values for\n"\
"# minute (m), hour (h), day of month (dom), month (mon),\n"\
"# and day of week (dow) or use '*' in these fields (for 'any').# \n"\
"# Notice that tasks will be started based on the cron's system\n"\
"# daemon's notion of time and timezones.\n"\
"# \n"\
"# Output of the crontab jobs (including errors) is sent through\n"\
"# email to the user the crontab file belongs to (unless redirected).\n"\
"# \n"\
"# For example, you can run a backup of all your user accounts\n"\
"# at 5 a.m every week with:\n"\
"# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/\n"\
"# \n"\
"# For more information see the manual pages of crontab(5) and cron(8)\n"\
"# \n"\
"# m h  dom mon dow   command\n"\
"\n"\
"0 2 * * 1 apt-get update -y && apt-get dist-upgrade -y\n" >> rootcrontab
sudo crontab rootcrontab
echo -en "\n-------------------------------------------------------\nSettup MOTD\n\n"
curl "$v_repo/kickstart/motd.sh" > /etc/motd.sh
sed -i --follow-symlinks '/motd.sh/d' /etc/bashrc
echo '[ -n "$PS1" ] && bash /etc/motd.sh' >> /etc/bashrc
echo -en "\n-------------------------------------------------------\nSetting up git\n\n"
cd $HOME
git config --global user.email "bbaumg@gmail.com"
git config --global user.name "Barrett"
git config --global credential.helper store
echo -en "\n-------------------------------------------------------\nInstall Dependencies\n\n"
cd $HOME
git clone https://github.com/jgarff/rpi_ws281x.git
cd rpi_ws281x
scons
cd python
sudo python3 setup.py install
echo -en "\n-------------------------------------------------------\nInstall Automation\n\n"
cd $HOME
git clone https://github.com/bbaumg/automation.git
#sudo bash automation/install.sh

echo -en "\n-------------------------------------------------------\nBuild Complete\n\n"
