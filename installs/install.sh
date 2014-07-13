#!/bin/bash

#log="/var/log/installs.log"
c_dir='/var/scripts/installs'
c_repo="https://raw.githubusercontent.com/bbaumg/scripts/master"
v_install="$c_dir/install.run"
#if [ -f "$log" ]; then exit 1; fi

logger () { 
  echo -e "\n==============================================================================\n$(date)  $1" | tee -a $v_log
}

if [ -f "$v_install" ]; then
        #source /var/scripts/functions.sh
        v_appname="$(cat $v_install | awk -F ', ' '{print $1}')"
        v_appurl="$(cat $v_install | awk -F ', ' '{print $2}')"
        v_log="$c_dir/$(cat $v_install | awk -F ', ' '{print $3}')"
        echo > $v_log
        logger "Install selection found...  Installing $v_appname"
        logger "Cleaning files so it does not run next time"
        sed -i --follow-symlinks '/install.sh/d' /etc/rc.local
        rm -f "$v_install"
        logger "Starting the Install...\n\n\n"
        sleep 5
        bash <(curl -sL "$v_appurl") 2>&1 | tee -a "$v_log"
        logger "Installation has completed"
else
        source <(curl -s "$c_repo/installs/list.sh")
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
                echo "${v_apps[$v_app]}" > $v_install
                sed -i --follow-symlinks '/install.sh/d' /etc/rc.local
                echo "curl -s $c_repo/installs/install.sh > $c_dir/install.sh" >> /etc/rc.local
                echo "chmod 755 $c_dir/install.sh" >> /etc/rc.local
                echo "bash $c_dir/install.sh" >> /etc/rc.local
                echo "Installation will begin when system resumes from the next reboot"
                if [ "$1" != 'firstboot' ]; then echo -n "System is rebooting now...  "; sleep 3; reboot; fi
        else
                echo -e "\n\n\n\n\n***********************************************************************"
                echo -e "There was an Error finding the appliation you selected"
                echo -e "***********************************************************************\n\n\n\n\n"
        fi

fi
