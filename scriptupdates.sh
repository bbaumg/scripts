#!/bin/bash

echo "Updating issue"
rm -f /etc/issue
wget --output-document=/etc/issue https://raw.github.com/bbaumg/scripts/master/issue
cp /etc/issue /etc/issue.$(date +"%Y%m%d%H%M%S")
echo "Updating MOTD"
rm -f /etc/motd.sh
wget --output-document=/etc/motd.sh https://raw.github.com/bbaumg/scripts/master/motd.sh
cp /etc/motd.sh /etc/motd.sh.$(date +"%Y%m%d%H%M%S")

echo "Completed updating scripts"
