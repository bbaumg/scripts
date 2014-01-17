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
else
        echo "finding"

fi
