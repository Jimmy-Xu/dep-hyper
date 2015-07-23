#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "The following command will be executed:" blue
echo "  sudo $(get_install_cmd) install tsocks"
echo ""

pause

sudo $(get_install_cmd) install tsocks

is_tsocks_installed