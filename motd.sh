#!/bin/bash
echo
echo 
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+     Hostname = $(hostname)"
echo "+   IP Address = $(ifconfig | sed -n '1 p' | awk '{print $1}') $(ifconfig | sed -n '2 p' | awk '{print $2}')"
echo "+           OS = $(cat /etc/redhat-release)"
echo "+       Uptime = $(uptime)"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
