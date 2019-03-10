#!/bin/bash

#Usage
#curl https://raw.githubusercontent.com/bbaumg/scripts/master/pi/headless.sh > headless.sh
#bash headless.sh

#based on information learned from
#https://core-electronics.com.au/tutorials/raspberry-pi-zerow-headless-wifi-setup.html

while true; do
    echo "........................."
    pwd
    echo "........................."
    read -p "Are you already in the boot directory (y/n)? " yn
    case $yn in
        [Yy]* )
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
            read -p "What SSID do you want to connect to? " wifiSSID
            #echo -en "\n$wifiSSID\n"
            echo -en "What is the Password? "
            read -s wifiPass
            echo -en "\nCreating wifi settings file 'wpa_supplicant.conf'\n"
            #echo -en "\n$wifiPass\n"
            echo -en "country=US\n"\
"ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n"\
"network={\n\tssid=\"$wifiSSID\"\n\tpsk=\"$wifiPass\"\n\tkey_mgmt=WPA-PSK\n}\n" > wpa_supplicant.conf
            break;;
        [Nn]* )
                echo "OK...  No Wireless"
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "Creating 'ssh' file in the root of boot"
touch ssh
echo "Build Complete"