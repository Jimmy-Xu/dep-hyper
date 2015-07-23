#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

echo "====================================================================="
show_message "1.check shadowsocks and privoxy installation..." green bold
is_shadowsocks_installed
is_privoxy_installed

echo "====================================================================="
show_message "2.stop shadowsocks ..." green bold
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
fi

show_message "3.stop privoxy ..." green bold
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
fi

echo "====================================================================="
show_message "4. check final status of shadowsocks and privoxy ..." green bold
is_shadowsocks_running "check"
is_privoxy_running "check"

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

# echo -e "export http_proxy=\n\
# export https_proxy=\n\
# export no_proxy=" >> ~/.bashrc

# show_message "Environment variables for proxy:" green
# grep "export.*proxy"  ~/.bashrc
# echo "-------------------------------------------------------------------"

# show_message "Please run 'source ~/.bashrc' to disable proxy" purple
