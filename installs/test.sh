#!/bin/bash
echo "installing Test..   Woot"
echo $1
if [ -n "$1" ]; then echo "now is when I would reboot"; fi
if [ "$1" == 'true' ]; then echo "rebooting"; fi
