#!/bin/bash
echo "installing Test..   Woot"
echo $1
if [ "$1" != 'firstboot' ]; then echo "rebooting"; fi
