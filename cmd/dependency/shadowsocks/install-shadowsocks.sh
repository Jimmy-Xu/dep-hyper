#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "The following command will be executed:" blue
echo "  sudo $(get_install_cmd) install python-pip"
echo "  sudo pip install shadowsocks"
echo ""

pause

show_message "install pip" green
sudo $(get_install_cmd) install python-pip

show_message "install shadowsocks" green
echo -e -n "${LEFT_PAD}${BOLD}${PURPLE}Use pypi in CN( http://pypi.douban.com )?${RESET} ('y' to use, 'Enter' to no):"
read CHOICE
if [ "$CHOICE" == "y" ];then
	sudo pip install shadowsocks -i ${PYPI_CN}
else
	sudo pip install shadowsocks
fi

if [ -f /usr/local/bin/sslocal -a ! -f /usr/bin/sslocal ];then
	sudo ln -s /usr/local/bin/sslocal /usr/bin/sslocal
fi

show_message "config shadowsocks service" green


check_deps_distro

sudo which systemctl >/dev/null 2>&1
if [ $? -eq 0 ];then
	if [[ "${LSB_DISTRO}" == "debian" ]] && [[ "${LSB_CODE}" == "jessie" ]];then
		echo "sudo cp ${BASE_DIR}/../../../etc/service/init.d/sslocal /etc/init.d/sslocal"
		sudo cp ${BASE_DIR}/../../../etc/service/init.d/sslocal /etc/init.d/sslocal
	else
		echo "cp ${BASE_DIR}/../../../etc/service/systemd/sslocal.service /lib/systemd/system/sslocal.service"
		sudo cp ${BASE_DIR}/../../../etc/service/systemd/sslocal.service /lib/systemd/system/sslocal.service
	fi
else
	echo "sudo cp ${BASE_DIR}/../../../etc/service/init.d/sslocal /etc/init.d/sslocal"
	sudo cp ${BASE_DIR}/../../../etc/service/init.d/sslocal /etc/init.d/sslocal
fi

is_shadowsocks_installed