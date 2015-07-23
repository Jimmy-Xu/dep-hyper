#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh


echo "====================================================================="
show_message "1.check shadowsocks, privoxy and awscli installation..." green bold
is_shadowsocks_installed
is_privoxy_installed

echo "====================================================================="
show_message "2.check shadowsocks, privoxy and awscli configuration..." green bold
show_message "privoxy configuration: /etc/privoxy/config" green
cat /etc/privoxy/config
echo "------------------------------------------------------------------"
echo ""
show_message "shadowsocks configuration: /etc/shadowsocks/client.json" green
if [ -f /etc/shadowsocks/client.json ];then
	cat /etc/shadowsocks/client.json
else
	echo "/etc/shadowsocks/client.json not exist!"
	exit 1
fi
echo "------------------------------------------------------------------"
echo ""
show_message "awscli configuration" green
aws configure list --profile hyper
echo "------------------------------------------------------------------"

echo
echo "====================================================================="
show_message "3.check shadowsocks, privoxy running..." green bold
is_shadowsocks_running "check"
is_privoxy_running "check"

echo
echo "====================================================================="
show_message "4.check port ..." green bold
SSLOCAL_PID=$(pgrep sslocal)"/python"
PRIVOXY_PID=$(pgrep privoxy)"/privoxy"
#echo "sudo netstat -tnopl | grep -E \"(8118.*-|\"${SSLOCAL_PID}\"|\"${PRIVOXY_PID}\")\""
sudo netstat -tnopl | grep -E "(8118.*-|"${SSLOCAL_PID}"|"${PRIVOXY_PID}")"
