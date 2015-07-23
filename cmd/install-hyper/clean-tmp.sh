#!/bin/bash
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh


CURRENT_USER="$(id -un 2>/dev/null || true)"
BOOTSTRAP_DIR="/tmp/hyper-bootstrap-${CURRENT_USER}"

sudo rm -rf ${BOOTSTRAP_DIR} >/dev/null 2>&1
if [ ! -d ${BOOTSTRAP_DIR} ];then
	show_message "${BOOTSTRAP_DIR} deleted" green
else
	show_message "delete ${BOOTSTRAP_DIR} failed" red
fi