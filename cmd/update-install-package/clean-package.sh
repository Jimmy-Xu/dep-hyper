#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

WORK_DIR=${BASE_DIR}/../../dist/

mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

ls hyper-*.tgz* 2>/dev/null | xargs -i \rm -rf {}
show_message "clean done" green

