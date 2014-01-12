#!/bin/bash
yum install -y wget vim lynx openssh-clients ntsysv ntp traceroute mysql-devel httpd httpd-devel curl curl-devel subversion
mkdir -p /var/www/rails
service iptables stop
service mysqld start
chkconfig httpd on
chkconfig iptables off
chkconfig mysqld on
cd $HOME
curl -L https://get.rvm.io | bash
source /etc/profile.d/rvm.sh
rvm install 2.0
yum install -y freetds freetds-devel
gem install rails -v 3.2.13
gem install passenger
passenger-install-apache2-module --auto | tee /var/www/rails/passenger_install.out
### NEED TO WRITE APACHE CONFIG FILE
svn export http://svn.redmine.org/redmine/branches/2.4-stable /var/www/rails/redmine
cp /var/www/rails/redmine/config/database.yml.example /var/www/rails/redmine/config/database.yml
### NED TO WRITE CONFIG FILE   vim /var/www/rails/redmine/config/database.yml
cd /var/www/rails/redmine/
gem install bundler
cd /var/www/rails/redmine/
bundle install --without development test rmagick
rake generate_secret_token
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake redmine:load_default_data
ruby script/rails server webrick -e production
