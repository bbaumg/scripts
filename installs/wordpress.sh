#!/bin/bash

# Variables & Constants
v_scripts='/var/scripts'
v_db='wordpress'
v_db_user='wordpress'
v_db_pw='password'
v_site='wordpress'
v_site_root='/var/www/html'
#v_site_ver='http://develop.svn.wordpress.org/tags/3.8.1/'
v_site_ver='http://wordpress.org/latest.zip'

# Modules
source "$v_scripts/functions.sh"


logger "Performing YUM installation"
yum install -y wget vim lynx mysql mysql-server php php-mysql httpd subversion unzip

logger "Set defaults and start services"
chkconfig mysqld on
service mysqld start
chkconfig httpd on
service httpd start
chkconfig iptables off
service iptables stop

logger "Create the database"
echo -e "create database $v_db character set utf8;\n"\
"create user '$v_db_user'@'localhost' identified by '$v_db_pw';\n"\
"grant all privileges on $v_db.* to '$v_db_user'@'localhost';\n"\
"flush privileges;\n"\
> $v_scripts/createdb.sql
cat $v_scripts/createdb.sql
mysql < $v_scripts/createdb.sql

logger "Download Wordpress"
#svn export $v_site_ver $v_site_root/$v_site
cd $v_site_root
wget $v_site_ver
unzip latest.zip
rm -f latest.zip

logger "Configure the wordpress instance"

logger "Configure httpd for new site"
echo > /etc/httpd/conf.d/$v_site.conf
echo -e "\nNameVirtualHost *:80\n"\
"<VirtualHost *:80>\n"\
"   UseCanonicalName Off\n"\
"   DocumentRoot /var/www/$v_site/\n"\
"   <Directory /var/www/$v_site/>\n"\
"      Options +FollowSymLinks\n"\
"      AllowOverride all\n"\
"      Order allow,deny\n"\
"      Allow from all\n"\
"   </Directory>\n"\
"</VirtualHost>\n"\
>> /etc/httpd/conf/httpd.conf
#/etc/httpd/conf.d/$v_site.conf
#cat /etc/httpd/conf.d/$v_site.conf
service httpd restart







