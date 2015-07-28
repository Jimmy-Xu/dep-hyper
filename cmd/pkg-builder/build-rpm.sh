#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "build rpm" green

PKG_BUILDER_DIR="${BASE_DIR}/../../pkg-builder"
cd ${PKG_BUILDER_DIR}

rm -rf *.rpm
make rpm

show_message "Done" green