#!/bin/bash

# Variables & Constants
v_scripts='/var/scripts'
v_db='wordpress'
v_db_user='wordpress'
v_db_pw='password'
v_site='wordpress'
v_site_ver='http://develop.svn.wordpress.org/tags/3.8.1/'

# Modules
source "$v_scripts/functions.sh"


logger "Performing YUM installation"
yum install -y wget vim lynx mysql mysql-server php php-mysql httpd subversion

logger "Create the database"
echo -e "create database $v_db character set utf8;\n"\
"create user '$v_db_user'@'localhost' identified by '$v_db_pw';\n"\
"grant all privileges on $v_db.* to '$v_db_user'@'localhost';\n"\
"flush privileges;\n"\
> $v_scripts/createdb.sql
cat $v_scripts/createdb.sql
mysql < $v_scripts/createdb.sql

svn export $v_site_ver /var/www/$v_site
