#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

check_proxy
export | grep proxy

show_message "The following command will be executed:" blue
echo "  sudo $(get_install_cmd) install python-pip"
echo "  sudo pip install awscli"
echo ""
pause

show_message "install pip" green
sudo $(get_install_cmd) install python-pip

show_message "install awscli" green

echo -e -n "${LEFT_PAD}${BOLD}${PURPLE}Use pypi in CN( http://pypi.douban.com )?${RESET} ('y' to use, 'Enter' to no):"
read CHOICE
if [ "$CHOICE" == "y" ];then
	sudo pip install awscli -i ${PYPI_CN}
else
	sudo pip install awscli
fi


is_awscli_installed
