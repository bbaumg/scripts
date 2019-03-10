#!/bin/bash

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
		read -p "What is the Password? " wifiPass
		echo 

                break;;
        [Nn]* )
                echo "OK...  No Wireless"
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
exit
echo "creating 'ssh' file in the root of boot"
touch ssh



#https://core-electronics.com.au/tutorials/raspberry-pi-zerow-headless-wifi-setup.html
Write the below to file "wpa_supplicant.conf"
country=AU
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
	ssid="MyWiFiNetwork"
	psk="aVeryStrongPassword"
	key_mgmt=WPA-PSK
}
