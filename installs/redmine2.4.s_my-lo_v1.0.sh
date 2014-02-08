#!/bin/bash

# Variables & Constants
v_scripts='/var/scripts'

# Modules
source "$v_scripts/functions.sh"


logger "Performing YUM installation"
yum install -y wget vim lynx openssh-clients ntsysv ntp traceroute mysql mysql-server mysql-devel httpd httpd-devel curl curl-devel subversion libyaml-devel
logger "Creating rails folder"
mkdir -p /var/www/rails
logger "Setting service run levels and starting services"
service iptables stop
service mysqld start
chkconfig httpd on
chkconfig iptables off
chkconfig mysqld on
logger "Beginning install of RVM"
bash <(curl -sL https://get.rvm.io)
source /etc/profile.d/rvm.sh
bash <(curl -sL https://get.rvm.io)
source /etc/profile.d/rvm.sh
logger "Installing Ruby"
rvm install 2.0
logger "Installing freetds"
yum install -y freetds freetds-devel
logger "Installing Rails"
gem install rails -v 3.2.13
logger "Installing passenger"
gem install passenger
passenger-install-apache2-module --auto | tee /var/www/rails/passenger_install.out

# Write the apache conf file & restart apache
logger "Building the apache config file"
grep -A 2 'LoadModule passenger_module' /var/www/rails/passenger_install.out\
          | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"\
          | sed 's/^ *//g'\
          > /etc/httpd/conf.d/redmine.conf
echo -e "\nNameVirtualHost *:80\n"\
"<VirtualHost *:80>\n"\
"   UseCanonicalName Off\n"\
"   SetEnv RAILS_ENV production\n"\
"   RewriteEngine On\n"\
"   # Rewrite index to check for static\n"\
"   RewriteRule ^/$ /index.html [QSA]\n"\
"   # Rewrite to check for Rails cached page\n"\
"   RewriteRule ^([^.]+)$ $1.html [QSA]\n"\
"   DocumentRoot /var/www/rails/redmine/public/\n"\
"   <Directory /var/www/rails/redmine/public/>\n"\
"      Options +FollowSymLinks\n"\
"      AllowOverride all\n"\
"      Order allow,deny\n"\
"      Allow from all\n"\
"   </Directory>\n"\
"</VirtualHost>\n"\
>> /etc/httpd/conf.d/redmine.conf
#cat /etc/httpd/conf.d/redmine.conf
logger "Restarting httpd service"
service httpd restart

# Dlownload Redmine
logger "Download Redmine from current stable"
svn export http://svn.redmine.org/redmine/branches/2.4-stable /var/www/rails/redmine

# Create the database connection file
logger "Build database connection file"
echo -e "# Config file written by installation script (bbaum)\n\n"\
"production:\n"\
"  adapter: mysql2\n"\
"  database: redmine\n"\
"  host:localhost\n"\
"  username: redmine\n"\
"  password: \"password\"\n"\
"  encoding: utf8\n"\
> /var/www/rails/redmine/config/database.yml
cat /var/www/rails/redmine/config/database.yml

# Create the database in MYSQL
logger "Create the database"
echo -e "create database redmine character set utf8;\n"\
"create user 'redmine'@'localhost' identified by 'password';\n"\
"grant all privileges on redmine.* to 'redmine'@'localhost';\n"\
"flush privileges;\n"\
> /var/www/rails/redmine/config/createdb.sql
cat /var/www/rails/redmine/config/createdb.sql
mysql < /var/www/rails/redmine/config/createdb.sql

# Install redmine
logger "Begin installing redmine"
cd /var/www/rails/redmine/
gem install bundler
cd /var/www/rails/redmine/
bundle install --without development test rmagick
rake generate_secret_token
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake redmine:load_default_data
#ruby script/rails server webrick -e production
