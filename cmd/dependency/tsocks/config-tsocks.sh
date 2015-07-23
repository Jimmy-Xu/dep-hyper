#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

CFG=${BASE_DIR}/../../../etc/tsocks.conf

if [ ! -f /etc/tsocks.conf.origin ];then
	show_message "backup /etc/tsocks.conf to /etc/tsocks.conf.origin"
	sudo cp /etc/tsocks.conf /etc/tsocks.conf.origin
fi

show_message "new tsocks config: [ ${BLUE}${CFG}${RESET} ] " green
cat ${CFG}
echo "----------------------------------------------"

show_message "current /etc/tsocks.conf:" green
cat /etc/tsocks.conf | grep -v "#" | grep -v "^$"
echo "----------------------------------------------"

echo -e -n "${LEFT_PAD}${PURPLE}Are you sure to cp ${BLUE}${CFG}${PURPLE} to ${BLUE}/etc/tsocks.conf${PURPLE} ?${RESET} ('y' to continue, 'Enter' to cancel):"
read CHOICE
if [ ! -z ${CHOICE} -a ${CHOICE} == "y" ];then
	sudo cp ${CFG} /etc/tsocks.conf
fi

show_message "show /etc/tsocks.conf:" green
cat /etc/tsocks.conf | grep -v "#" | grep -v "^$"
echo "----------------------------------------------"
