#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "uninstall deb" green


PKG_BUILDER_DIR="${BASE_DIR}/../../pkg-builder"
cd ${PKG_BUILDER_DIR}

pwd
sudo dpkg -r hyper
sudo dpkg -P hyper


show_message "Done" green