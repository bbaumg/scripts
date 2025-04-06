#!/bin/bash
echo
echo
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+     Hostname = $(hostname)"
v_pimodel=$(cat /proc/cpuinfo | grep 'Model' | awk '{for (i=3; i <= NF; i++) printf("%s ", $i); print ""}')
if [ "$v_pimodel" != "" ]; then
	echo "+     Pi Model = $v_pimodel"
fi
echo "+   IP Address = $(ip --brief address | awk '/UP/ {print $3, "on", $1}')"
echo "+           OS = $(cat /etc/*-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/"//g')"
echo "+          CPU = $(nproc) Core(s)"
echo "+       Memory = $(cat /proc/meminfo | sed -n '1 p' |awk '{print $2/1024}' | awk -F . '{print $1}') MB"
echo "+       Uptime =$(uptime)"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
