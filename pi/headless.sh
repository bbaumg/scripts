#!/bin/bash

while true; do
    echo "........................."
    pwd
    echo "........................."
    read -p "Are you already in the boot directory (y/n)? " yn
    case $yn in
        [Yy]* )
                echo "Updates will be scheduled weekly."
                var_Upgrade='Y'
                break;;
        [Nn]* )
                echo "OK...  Exiting.  Go there first"
                exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you want to setup wireless (y/n)? " yn
    case $yn in
        [Yy]* )
                echo "Updates will be scheduled weekly."
                var_Upgrade='Y'
                break;;
        [Nn]* )
                echo "OK...  No Wireless"
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "creating 'ssh' file in the root of boot"
touch ssh




Write the below to file "wpa_supplicant.conf"
country=AU
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
	ssid="MyWiFiNetwork"
	psk="aVeryStrongPassword"
	key_mgmt=WPA-PSK
}
