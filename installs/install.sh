#!/bin/bash

log="/var/log/installs.log"
c_dir='/var/scripts/installs'
install="$c_dir/install.run"
github="https://raw.github.com/bbaumg/scripts/master/installs"
if [ -f "$log" ]; then
        exit 1
fi
mkdir -p $c_dir
if [ -f "$install" ]; then
        echo "running"
        #v_app[0]="$(grep v_apps $install) | awk -F ', ' '{print $1}'"
        #v_app[1]="$(grep v_apps $install) | awk -F ', ' '{print $2}'"
        #v_app[2]="$(grep v_apps $install) | awk -F ', ' '{print $3}'"
        #echo "Installation selection found...  Installing $(echo ${v_app[0]}"
        #curl -sL $(echo "${v_app[1]}" | bash 2>&1 | tee $(echo "${v_apps[2}" | awk -F', ' '{print $3}')"
else
        echo "finding"

fi
