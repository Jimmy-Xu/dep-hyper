#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "The following command will be executed:" blue
echo "  sudo $(get_install_cmd) install privoxy"
echo ""

pause

show_message "install privoxy" green
sudo $(get_install_cmd) install privoxy

is_privoxy_installed