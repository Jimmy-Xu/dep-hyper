#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

is_shadowsocks_installed

sudo pgrep sslocal >/dev/null 2>&1
if [ $? -eq 0 ];then
	show_message "shadowsocks is running, now stop it!" green
	if (command_exist service);then
		sudo service sslocal stop
		sleep 2
		sudo service sslocal status
	else
		sudo systemctl stop sslocal
		sleep 2
		sudo systemctl status sslocal
	fi
	sleep 1
else
	show_message "shadowsocks already stopped, cancel stop" yellow bold
	exit 1
fi

is_shadowsocks_running