#!/bin/bash

#log="/var/log/installs.log"
c_dir='/var/scripts/installs'
install="$c_dir/install.run"
github="https://raw.github.com/bbaumg/scripts/master/installs"
#if [ -f "$log" ]; then exit 1; fi

if [ -f "$install" ]; then
        v_app[0]="$(cat $install | awk -F ', ' '{print $1}')"
        v_app[1]="$(cat $install | awk -F ', ' '{print $2}')"
        v_app[2]="$(cat $install | awk -F ', ' '{print $3}')"
        echo "Installation selection found...  Installing ${v_app[0]}"
        awk '!/install.sh/' /etc/rc.local > /etc/rc.local.tmp && mv -f /etc/rc.local.tmp /etc/rc.local
        rm -f $install
        bash <(curl -sL ${v_app[1]}) 2>&1 | tee ${v_app[2]}
        #curl -sL $(echo "${v_app[1]}" | bash 2>&1 | tee $(echo "${v_apps[2}" | awk -F', ' '{print $3}')"
else
        source <(curl -sL "$github/list.sh")
        if [ -z ${v_apps[0]} ]; then
                echo -e "\n\n\n\n\n***********************************************************************"
                echo -e "Unable to load the list of installation options"
                echo -e "***********************************************************************\n\n\n\n\n"
                exit 1
        fi
        
        echo -en "Template Applications:\n"
        for (( i = 0 ; i< ${#v_apps[@]} ; i++ )) do
                echo -e "  [$i = $(echo "${v_apps[$i]}" | awk -F', ' '{print $1}')]"
        done
        echo -en "Should we install an app [0-9]: "
        read v_app
        
        if [ "$v_app" = 0 ]; then
                echo -e "\nNo applications selected for install\n"
        elif [ -n "$(echo "${v_apps[$v_app]}" | awk -F', ' '{print $1}')" ] && \
             [ -n "$(echo "${v_apps[$v_app]}" | awk -F', ' '{print $2}')" ] && \
             [ -n "$(echo "${v_apps[$v_app]}" | awk -F', ' '{print $3}')" ]; then
                echo "$(echo "${v_apps[$v_app]}" | awk -F', ' '{print $1}') will install after the next reboot"
                mkdir -p $c_dir
                #echo "${v_apps[$v_app]}" | tee $install
                echo "bash <(curl -sL $github/install.sh)" >> /etc/rc.local
                echo "System is rebooting now...  Installation will begin when system resumes"
                sleep 3
                #shutdown -r now
        else
                echo -e "\n\n\n\n\n***********************************************************************"
                echo -e "There was an Error finding the appliation you selected"
                echo -e "***********************************************************************\n\n\n\n\n"
        fi

fi
