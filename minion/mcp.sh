#!/bin/bash
#########################################################################
# MCP (Minion Control Program)
#########################################################################

# Variables
debug=''
v_installdir='/var/scripts'
v_dir="$v_installdir/minion"
v_logdir='/var/log/minion'
v_status="$v_logdir/mcp.sts"
v_log="$v_logdir/mcp.log"
v_initd='/etc/init.d/mcpd'
v_daemon="$v_dir/mcpd"
v_svnpath='https://svn/minion/lv1'
v_svnuser='genminionlinux'
v_svnpass='K7boLIS9M6pMBZ2j346K'

# Functions...
logger () { echo -e "$(date)  $1" | tee -a $v_log; }

# First let's install if it is not already installed.
#  Make sure the log directory is there
#  Create the log folders
if [ "$debug" ]; then echo -en ""; fi
if [ "$debug" ]; then echo -en "Creating $v_logdir directory"; fi
if [ ! -d $v_logdir ]; then mkdir -p $v_logdir; fi
logger "Startup..."

#  Install the script iteself
if [ ! -d "$v_installdir" ] || [ ! -d "$v_dir" ]; then
	logger "The minions are not installed...  Installing"
	sleep 3
	echo -en "Installing SVN...\n" | tee -a $v_log
	yum install -y -q subversion
	echo -en "SVN Install Complete\nInstalling files..." | tee -a $v_log
	mkdir -p $v_installdir
	cd $v_installdir
	svn checkout --no-auth-cache --trust-server-cert --non-interactive --quiet --username $v_svnuser --password $v_svnpass $v_svnpath $v_dir
	echo -en "File Install Complete\n" | tee -a $v_log
	echo -en "\n\n$(date)" >> $v_log
	sleep 3
fi

#  Download the current version
if [ "$debug" ]; then echo -en "\nDownloading the most current version:  "; fi
cd $v_dir
svn update --no-auth-cache --trust-server-cert --non-interactive --username $v_svnuser --password $v_svnpass
if [ "$debug" ]; then echo -en "Update Complete\n"; sleep 3; fi

#  Install the init.d script
if [ "$debug" ]; then echo -e "\nChecking the daemon version"; fi
if [ "$v_initd" -ot "$v_daemon" ] || [ ! -f "$v_initd" ]; then
	echo "The daemon is either an older version or not instaled.  Installing/updating..."
	cp "$v_daemon" "$v_initd"
	chmod 755 "$v_initd"
	echo -e "Restarting daemon\n"
	service mcpd restart
	sleep 1
	echo -e "\nService Restarted"
	sleep 3
	exit 0
else
	if [ "$debug" ]; then echo "Daemon version is current"; sleep 3; fi
fi
#  Create the log folders
if [ ! -d $v_logdir ]; then
	mkdir -p $v_logdir
fi

v_runtime=$(date +%S)

# Now for the actual program
if [ "$debug" ]; then echo -e "Now we are actually starting the minion\n\n\n"; sleep 3; fi
while [ true ]; do
	v_statehdr="***********************************\n*  MCP (Minion Control Program)\n*\n*  $(date)"
	v_statehdr+="\n***********************************\nStart Second: $v_runtime \n\n"
	if [ "$debug" ]; then 
		clear
	        echo -e "$v_statehdr"
		for i in {1..25}; do echo ${v_history[$i]}; done
	fi
	if [ "$(date +%S)" -eq "$v_runtime" ]; then
	#if [ "$(date +%S)" -eq "$v_runtime" ] || [ true ]; then
	        # Update the job history
		for i in {25..1}; do v_history[$i]=${v_history[$i-1]}; done
		v_history[1]="$(date)     Checking for jobs to run:"
		# Query the DB to see if there are any jobs to run
		if [ -n "$v_jobs" ]; then
			v_history[1]+="  There are jobs to run\n"
		else
			v_history[1]+="  There are NO jobs to run\n"
		fi
		# Update the status file
                echo -e "$v_statehdr" > $v_status
                for i in {1..25}; do echo ${v_history[$i]} >> $v_status; done
	fi
# ToDo:
# check for restart
# query for jobs to execute







	sleep 1
done
