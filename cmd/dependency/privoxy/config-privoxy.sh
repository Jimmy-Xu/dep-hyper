#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

CFG=${BASE_DIR}/../../../etc/privoxy/config

if [ ! -f /etc/privoxy/config.origin ];then
	show_message "backup /etc/privoxy/config to /etc/privoxy/config.origin"
	sudo cp /etc/privoxy/config /etc/privoxy/config.origin
fi

show_message "source privoxy config: [ ${BLUE}${CFG}${RESET} ] " green
cat ${CFG}
echo "----------------------------------------------"

show_message "target /etc/privoxy/config:" green
cat /etc/privoxy/config | grep -v "#" | grep -v "^$"
echo "----------------------------------------------"

echo -e -n "${LEFT_PAD}${PURPLE}Are you sure to cp ${BLUE}${CFG}${PURPLE} to ${BLUE}/etc/privoxy/config${PURPLE} ?${RESET} ('y' to continue, 'Enter' to cancel):"
read CHOICE
if [[ ! -z ${CHOICE} ]] && [[ ${CHOICE} == "y" ]];then
	sudo cp ${CFG} /etc/privoxy/config
else
	echo "cancelled"
fi

show_message "show current /etc/privoxy/config:" green
cat /etc/privoxy/config | grep -v "#" | grep -v "^$"
echo "----------------------------------------------"
