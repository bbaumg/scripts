#!/bin/bash
entname=$(ip addr | awk -F ": " '!/  /{print $2}' | grep --invert-match 'lo')
echo
echo
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+     Hostname = $(hostname)"
#echo "+   IP Address = $(ifconfig | sed -n '1 p' | awk '{print $1}') $(ifconfig | sed -n '2 p' | awk '{print $2}')"
echo "+   IP Address = $(ip addr show $entname | grep 'inet ' | awk '{print $2}') on $entname"
echo "+           OS = $(cat /etc/system-release)"
echo "+          CPU = $(nproc) Core(s)"
echo "+       Memory = $(cat /proc/meminfo | sed -n '1 p' |awk '{print $2/1024}' | awk -F . '{print $1}') MB"
echo "+       Uptime =$(uptime)"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
