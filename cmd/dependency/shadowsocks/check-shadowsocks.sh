#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

is_shadowsocks_installed
is_shadowsocks_configured
is_shadowsocks_running