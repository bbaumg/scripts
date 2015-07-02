#!/bin/bash

curl ""

sudo raspi-config
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y python3-pip python3-dev vim git-core locate
sudo pip-3.2 install pyephem pymysql configparser
echo -en "\n# Some stuff I added\n"\
"alias ll='ls -alh'\n"\
"export EDITOR=vim\n" >> .bashrc

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
cd $HOME
git config --global user.email "bbaumg@gmail.com"
git config --global user.name "Barrett"
git config --global credential.helper store
git clone https://github.com/bbaumg/automation.git
sudo bash automation/install.sh
