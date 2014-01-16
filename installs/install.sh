#!/bin/bash

log="/var/log/installs.log"
if [ -f "$log" ]; then
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
        echo -en "Installing $(echo "${v_apps[$v_app]}" | awk -F', ' '{print $1}')...  Please wait while the install script is downloaded\n\n"
        #v_install="$(echo "${v_apps[$v_app]}" | awk -F', ' '{print $2}')"
        #echo "$v_install"
        #v_install="curl -sL $(echo "${v_apps[$v_app]}" | awk -F', ' '{print $2}') | bash 2>&1 | tee $(echo "${v_apps[$v_app]}" | awk -F', ' '{print $3}')"
        v_install="${v_apps[$v_app]}"
        echo "$v_install"
        
        
        echo "bash /var/scripts/installs/install.sh | tee $log"  >> /etc/rc.local


else
        echo -e "\n\n\n\n\n***********************************************************************"
        echo -e "There was an Error finding the appliation you selected"
        echo -e "***********************************************************************\n\n\n\n\n"
fi
