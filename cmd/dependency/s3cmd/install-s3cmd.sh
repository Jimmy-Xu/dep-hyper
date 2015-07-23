#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

check_proxy
export | grep proxy

show_message "The following command will be executed:" blue
echo "  sudo $(get_install_cmd) install python-pip"
echo "  sudo pip install s3cmd"
echo ""
pause

show_message "install pip" green
sudo $(get_install_cmd) install python-pip

show_message "install s3cmd" green
echo -e -n "${LEFT_PAD}${BOLD}${PURPLE}Use pypi in CN( http://pypi.douban.com )?${RESET} ('y' to use, 'Enter' to no):"
read CHOICE
if [ "$CHOICE" == "y" ];then
	sudo pip install s3cmd -i ${PYPI_CN}
else
	sudo pip install s3cmd
fi



is_s3cmd_installed
