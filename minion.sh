#!/bin/bash
echo '----------------------------------------------------------------------------------------'
echo 'Minion is starting to run'
echo "$(date)"
echo "Updating banner"
rm -f /etc/issue
wget --output-document=/etc/issue https://raw.github.com/bbaumg/scripts/master/banner
cp /etc/issue /etc/issue.$(date +"%Y%m%d%H%M%S")

echo "Updating MOTD"
rm -f /etc/motd.sh
wget --output-document=/etc/motd.sh https://raw.github.com/bbaumg/scripts/master/motd.sh
cp /etc/motd.sh /etc/motd.sh.$(date +"%Y%m%d%H%M%S")

echo "Getting scripts:"
echo "  create_ssl_cert.sh"
wget --output-document=/var/scritps/create_ssl_cert.sh https://raw.github.com/bbaumg/scripts/master/create_ssl_cert.sh

echo "YUM update"
yum update -y
echo "Cleanup installs"
yum clean all

echo "$(date)"
echo "Minion is done working"
