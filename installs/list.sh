#!/bin/bash
# List the systems to install 'NAME, URL, LOGFILE)
v_apps[0]="None"
v_apps[1]='Redmine, https://raw.github.com/bbaumg/scripts/master/installs/redmine2.4.s_my-lo_v1.0.sh, /var/log/app_install_redmine.log'
v_apps[2]='List, https://raw.github.com/bbaumg/scripts/master/installs/list.sh, /var/log/app_install_list.log'

echo -en "Template Applications:\n"
for (( i = 0 ; i< ${#v_apps[@]} ; i++ )) do
        echo -e "  [$i = $(echo "${v_apps[$i]}" | awk -F', ' '{print $1}')]"
done
echo -en "Should we install an app [0-9]: "
read v_app
