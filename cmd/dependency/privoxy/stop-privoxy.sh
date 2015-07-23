#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

is_privoxy_installed

sudo ps -ef | grep privoxy | grep -v grep | grep -v privoxy.sh >/dev/null 2>&1
if [ $? -eq 0 ];then
	show_message "privoxy is running, now stop it!" green
	if (command_exist service);then
		sudo service privoxy stop
		sleep 2
		sudo service privoxy status
	else
		sudo systemctl stop privoxy
		sleep 2
		sudo systemctl status privoxy
	fi
	sleep 1
else
	show_message "privoxy already stopped, cancel stop" yellow bold
	exit 1
fi

is_privoxy_running