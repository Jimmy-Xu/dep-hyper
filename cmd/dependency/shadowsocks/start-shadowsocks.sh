#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

SS_LOG=${BASE_DIR}/../../../log/sslocal.log

is_shadowsocks_installed

sudo pgrep sslocal >/dev/null 2>&1
if [ $? -eq 0 ];then
	show_message "shadowsocks already running, cancel start" green
	exit 1
else
	show_message "shadowsocks isn't running, now start it!" green
	if [ -f /etc/shadowsocks/client.json ];then
		if (command_exist service);then
			sudo service sslocal start
			sleep 2
			sudo service sslocal status
		else
			sudo systemctl start sslocal
			sleep 2
			sudo systemctl status sslocal
		fi
	else
		show_message "/etc/shadowsocks/client.json not exist!" red
		exit 1
	fi
fi

is_shadowsocks_running