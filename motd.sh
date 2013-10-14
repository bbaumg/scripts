#!/bin/bash
echo
echo 
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+     Hostname = $(hostname)"
echo "+   IP Address = $(ifconfig | sed -n '1 p' | awk '{print $1}') $(ifconfig | sed -n '2 p' | awk '{print $2}')"
echo "+           OS = $(cat /etc/redhat-release)"
echo "+          CPU = $(nproc) Cores"
echo "+       Memory = $(cat /proc/meminfo | sed -n '1 p' |awk '{print $2/1024}' | awk -F . '{print $1}') MB"
echo "+       Uptime = $(uptime)"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
