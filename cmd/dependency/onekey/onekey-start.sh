#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

SS_LOG=${BASE_DIR}/../../../log/sslocal.log

echo "====================================================================="
show_message "1.check shadowsocks and privoxy installation..." green bold
is_shadowsocks_installed
is_privoxy_installed

echo "====================================================================="
show_message "2.start shadowsocks ..." green bold
sudo pgrep sslocal >/dev/null 2>&1
if [ $? -eq 0 ];then
	show_message "shadowsocks already running, cancel start" green
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

show_message "3.start privoxy ..." green bold
sudo ps -ef | grep privoxy | grep -v grep | grep -v privoxy.sh >/dev/null 2>&1
if [ $? -eq 0 ];then
	show_message "privoxy already running, cancel start" green
else
	show_message "privoxy isn't running, now start it!" green
	if (command_exist service);then
		sudo service privoxy start
		sleep 2
		sudo service privoxy status
	else
		sudo systemctl start privoxy
		sleep 2
		sudo systemctl status privoxy
	fi
fi

echo "====================================================================="
show_message "4. check final status of shadowsocks and privoxy ..." green bold
is_shadowsocks_running
is_privoxy_running

echo
echo "====================================================================="
show_message "5.check port ..." green bold
SSLOCAL_PID=$(pgrep sslocal)"/python"
PRIVOXY_PID=$(pgrep privoxy)"/privoxy"
#echo "sudo netstat -tnopl | grep -E \"(8118.*-|\"${SSLOCAL_PID}\"|\"${PRIVOXY_PID}\")\""
sudo netstat -tnopl | grep -E "(8118.*-|"${SSLOCAL_PID}"|"${PRIVOXY_PID}")"

# echo
# echo "====================================================================="
# show_message "6.update ~/.bashrc ..." green bold

# sed -i -e "/^export http_proxy=/d" ~/.bashrc
# sed -i -e "/^export https_proxy=/d" ~/.bashrc
# sed -i -e "/^export no_proxy=/d" ~/.bashrc

# echo -e "export http_proxy=http://localhost:8118\n\
# export https_proxy=http://localhost:8118\n\
# export no_proxy=localhost,127.0.0.0/8,::1,/var/run/docker.sock" >> ~/.bashrc

# show_message "Environment variables for proxy:" green
# grep "export.*proxy"  ~/.bashrc
# echo "-------------------------------------------------------------------"

# show_message "Please run 'source ~/.bashrc' to enable proxy" purple
