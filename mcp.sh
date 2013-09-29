#!/bin/bash

v_control="/var/scripts/control"
cat $v_control
if [ -f "$v_control" ]; then
  v_status=`cat $v_control`
else
  echo "UPDATE" > $v_control
fi

if [ "$v_status" = "UPDATE" ]; then
  wget --output-document=/var/scripts/mcp.sh https://raw.github.com/bbaumg/scripts/master/mcp.sh
  echo "RUN" > $v_control
  bash "/var/scripts/mcp.sh"
  exit1
else if [ "$v_status" = "RUN" ]; then

fi



echo "Updating issue"
rm -f /etc/issue
wget --output-document=/etc/issue https://raw.github.com/bbaumg/scripts/master/banner
cp /etc/issue /etc/issue.$(date +"%Y%m%d%H%M%S")
echo "Updating MOTD"
rm -f /etc/motd.sh
wget --output-document=/etc/motd.sh https://raw.github.com/bbaumg/scripts/master/motd.sh
cp /etc/motd.sh /etc/motd.sh.$(date +"%Y%m%d%H%M%S")

echo "Completed updating scripts"
