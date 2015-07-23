#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

CFG=${BASE_DIR}/../../../etc/shadowsocks/client.json
TGT_CFG=/etc/shadowsocks/client.json

JQ_BIN=${BASE_DIR}/../../../util/jq


show_message "config shadowsocks" green

show_message "shadowsocks config template: [ ${BLUE}${CFG}${RESET} ] " green
cat ${CFG}
echo "----------------------------------------------"

sudo mkdir -p /etc/shadowsocks
if [ -f ${TGT_CFG} ];then
	show_message "current shadowsocks config : ${TGT_CFG}:" green
	${JQ_BIN} -r "." ${TGT_CFG}
	echo "----------------------------------------------"
fi


echo -e -n "${LEFT_PAD}${PURPLE}Are you sure to modify shadowsocks config?${PURPLE} ?${RESET} ('y' to continue, 'Enter' to cancel):"
read CHOICE
if [[ ! -z ${CHOICE} ]] && [[ ${CHOICE} == "y" ]];then

	DFT_SERVER_PORT="8388"
	DFT_LOCAL_PORT="1080"
	DFT_TIMEOUT="600"
	DFT_METHOD="aes-256-cfb"

	show_message "Please input the parameter for shadowsocks client, server and password can not be empty"

	echo -e -n "server(input ip)   :"                      ; read SERVER
	if [ -z ${SERVER} ];then
		show_message "server can not be empty" red
		exit 1
	fi

	echo -e -n "server_port(${DFT_SERVER_PORT})  :" ; read SERVER_PORT
	echo -e -n "local_port(${DFT_LOCAL_PORT})   :"   ; read LOCAL_PORT

	echo -e -n "password           :"                    ; read -s PASSWORD
	if [ -z ${PASSWORD} ];then
		show_message "password can not be empty" red
		exit 1
	fi
	echo
	echo -e -n "timeout(${DFT_TIMEOUT})       :"         ; read TIMEOUT
	echo -e -n "method(${DFT_METHOD}):"           ; read METHOD

	if [ -z ${SERVER_PORT} ];then SERVER_PORT=$DFT_SERVER_PORT; fi
	if [ -z ${LOCAL_PORT} ];then LOCAL_PORT=$DFT_LOCAL_PORT; fi
	if [ -z ${TIMEOUT} ];then TIMEOUT=$DFT_TIMEOUT; fi
	if [ -z ${METHOD} ];then METHOD=$DFT_METHOD; fi

	echo  "{" > ${CFG}.tmp
	echo  "  \"server\"  : \"${SERVER}\"," >> ${CFG}.tmp
	echo  "  \"server_port\": ${SERVER_PORT}," >> ${CFG}.tmp
	echo  "  \"local_port\": ${LOCAL_PORT}," >> ${CFG}.tmp
	echo  "  \"password\": \"${PASSWORD}\"," >> ${CFG}.tmp
	echo  "  \"timeout\": ${TIMEOUT}," >> ${CFG}.tmp
	echo  "  \"method\": \"${METHOD}\"" >> ${CFG}.tmp
	echo  "}" >> ${CFG}.tmp

	${JQ_BIN} -r "." ${CFG}.tmp

	echo -e -n "${LEFT_PAD}${PURPLE}Confirm to replace ${TGT_CFG}?${RESET} ('y' to confirm, 'Enter' to cancel):"
	read CHOICE
	if [ "$CHOICE" == "y" ];then
		sudo mv ${CFG}.tmp ${TGT_CFG}
		show_message "done!"
	fi
else
	echo "cancelled"
fi

if [ -f ${CFG}.tmp ];then
	rm ${CFG}.tmp -rf
fi

show_message "show current ${TGT_CFG}:" green
cat ${TGT_CFG} | grep -v "#" | grep -v "^$"
echo "----------------------------------------------"