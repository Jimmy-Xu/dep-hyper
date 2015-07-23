#!/bin/bash

export PATH=/usr/local/bin:/usr/local/sbin:${PATH}

###################################################
# variable(customizable)
###################################################
HYPER_PROFILE="hyper"
UNTAR_DIR="hyper-pkg"

PYPI_CN="http://pypi.douban.com/simple"

###################################################
# function
###################################################
#pause
function pause() {
  read -n 1 -p "${LEFT_PAD}${BLUE}Press any key to continue...${RESET}"
}

function command_exist() {
  type "$@" > /dev/null 2>&1
}

function run_cmd() {
  echo -e "\n[$(date +'%F %T')] execute cmd =>\n  [ $1 ]"
  $1
}

function get_install_cmd() {
	if (command_exist apt-get);then
		echo "apt-get"
	else
		echo "yum"
	fi
}

check_deps_distro() {
  LSB_DISTRO=""; LSB_VER=""; LSB_CODE=""
  if (command_exist lsb_release);then
    LSB_DISTRO="$(lsb_release -si)"
    LSB_VER="$(lsb_release -sr)"
    LSB_CODE="$(lsb_release -sc)"
  fi
  if [ -z "${LSB_DISTRO}" ];then
    if [ -r /etc/lsb-release ];then
      LSB_DISTRO="$(. /etc/lsb-release && echo "${DISTRIB_ID}")"
      LSB_VER="$(. /etc/lsb-release && echo "${DISTRIB_RELEASE}")"
      LSB_CODE="$(. /etc/lsb-release && echo "${DISTRIB_CODENAME}")"
    elif [ -r /etc/os-release ];then
      LSB_DISTRO="$(. /etc/os-release && echo "$ID")"
      LSB_VER="$(. /etc/os-release && echo "$VERSION_ID")"
    elif [ -r /etc/fedora-release ];then
      LSB_DISTRO="fedora"
    elif [ -r /etc/debian_version ];then
      LSB_DISTRO="Debian"
      LSB_VER="$(cat /etc/debian_version)"
    fi
  fi
  LSB_DISTRO=$(echo "${LSB_DISTRO}" | tr '[:upper:]' '[:lower:]')
  if [ "${LSB_DISTRO}" == "debian" ];then
    case ${LSB_VER} in
      8) LSB_CODE="jessie";;
      7) LSB_CODE="wheezy";;
    esac
  fi
}

function is_shadowsocks_installed() {
	type sslocal >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "shadowsocks is installed:)" green
		sslocal --version
	else
		show_message "shadowsocks isn't installed:(" red bold
		exit 1
	fi
}

#check if hyper is cloned to local
function is_shadowsocks_running() {
	sudo pgrep sslocal >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "shadowsocks is running" green
	else
		show_message "shadowsocks is stopped" yellow bold
		if [ $# -eq 0 -o "$1" != "check" ];then
			exit 1
		fi
	fi
}

function is_shadowsocks_configured() {
	if [ -f /etc/shadowsocks/client.json ];then
		show_message "shadowsocks is configured" green
	else
		show_message "shadowsocks isn't configured, missing /etc/shadowsocks/client.json" red
		exit 1
	fi
}

function is_privoxy_installed() {
	sudo which privoxy >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "privoxy is installed:)" green
		sudo privoxy --version
	else
		show_message "privoxy isn't installed:(" red bold
		exit 1
	fi
}

#check if hyper is cloned to local
function is_privoxy_running() {
	sudo ps -ef | grep privoxy | grep -v grep | grep -v privoxy.sh >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "privoxy is running" green
	else
		show_message "privoxy is stopped" yellow bold
		if [ $# -eq 0 -o "$1" != "check" ];then
			exit 1
		fi
	fi
}

function is_awscli_installed() {
	which aws >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "awscli is installed:)" green
		aws --version
	else
		show_message "awscli isn't installed:(" red bold
		exit 1
	fi
}

function is_awscli_configured() {
	aws configure list --profile hyper >/dev/null 2>&1
	if [ $? -eq 0 ];then
		NOT_SET=$(aws configure list --profile hyper | grep "<not set>" | wc -l)
		if [ ${NOT_SET} -ne 0 ];then
			show_message "awscli configured not finish, please run configure again!" red
			exit 1
		else
			show_message "awscli is configured:)" green
			aws configure list --profile hyper
		fi
	else
		show_message "awscli not configure for hyper, please run configure first!" red
		exit 1
	fi
}

function is_s3cmd_installed() {
	which s3cmd >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "s3cmd is installed:)" green
		s3cmd --version
	else
		show_message "s3cmd isn't installed:(" red bold
		exit 1
	fi
}

function is_s3cmd_configured() {
	cat ~/.s3cfg >/dev/null 2>&1
	if [ $? -eq 0 ];then
		ACCESS_KEY=$(cat ~/.s3cfg | grep -E "(access_key)" | wc -w)
		SECRET_KEY=$(cat ~/.s3cfg | grep -E "(secret_key)" | wc -w)
		if [[ ${ACCESS_KEY} -eq 2 ]] || [[ ${SECRET_KEY} -eq 2 ]] ;then
			show_message "s3cmd configured not finish, please run configure again!" red
			exit 1
		else
			show_message "s3cmd is configured:)" green
		fi
	else
		show_message "s3cmd not configure, please run configure first!" red
		exit 1
	fi
}

function is_tsocks_installed() {
	which tsocks >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "tsocks is installed:)" green
	else
		show_message "tsocks isn't installed:(" red bold
		exit 1
	fi
}

function check_proxy() {

	#check proxy
	sudo pgrep sslocal >/dev/null 2>&1
	if [ $? -eq 0 ];then
		SHADOWSOCKS_RUNNING="true"
	else
		SHADOWSOCKS_RUNNING="false"
	fi

	sudo ps -ef | grep privoxy | grep -v grep | grep -v privoxy.sh >/dev/null 2>&1
	if [ $? -eq 0 ];then
		PRIVOXY_RUNNING="true"
	else
		PRIVOXY_RUNNING="false"
	fi

	if [[ ${SHADOWSOCKS_RUNNING} == "true" ]] && [[ ${PRIVOXY_RUNNING} == "true" ]];then
		show_message "enable proxy" blue bold
		export http_proxy=http://localhost:8118
		export https_proxy=http://localhost:8118
		export no_proxy=localhost,127.0.0.0/8,::1,/var/run/docker.sock
	else
		show_message "disable proxy" blue bold
		export http_proxy=
		export https_proxy=
		export no_proxy=
	fi

}

#check GOPATH before clone hyper and hyperinit
function is_tar_gz_valid() {
	TAR_FILE=$1

	if [ $# -eq 0 ]
	then
		echo -e "\nno file to check,cancel\n"
		exit 1
	fi

	if [ ! -f "${TAR_FILE}" ]
	then
		echo -e "\ncan not found file ${TAR_FILE},cancel\n"
		exit 1
	fi

	tar ztvf "${TAR_FILE}" > /dev/null
	if [ $? -ne 0 ]
	then
		echo -e "\nfile ${TAR_FILE} is bad! remove now\n"
		rm ${TAR_FILE}
	fi
}

#check if hyper is cloned to local
function is_hyper_exist() {
	if [ ! -d "$GOPATH/src/${HYPER_CLONE_DIR}" ]
	then
		show_message "$GOPATH/src/${HYPER_CLONE_DIR} doesn't exist! please clone it first!" red bold
		exit 1
	fi
}

#check if hyperinit is cloned to local
function is_hyperinit_exist() {
	if [ ! -d "$GOPATH/src/${HYPERINIT_CLONE_DIR}" ]
	then
		show_message "$GOPATH/src/${HYPERINIT_CLONE_DIR} doesn't exist! please clone it first!" red bold
		exit 1
	fi
}

#check if hyper is cloned to local
function is_hyperd_running() {
	pgrep hyperd >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "hyperd is running:)" green
	else
		show_message "hyperd isn't running:(" red bold
		exit 1
	fi
}

#check if hyper is cloned to local
function is_hyper_cli_installed() {
	which hyper
	if [ $? -eq 0 ]
	then
		show_message "hyper client is installed:)" green
		hyper version
	else
		show_message "hyper client isn't installed:(" red bold
		exit 1
	fi
}

function get_os_distro(){

	SUPPORT_OS_TYPE=(Linux MINGW32)
	SUPPORT_OS_DISTRO=(Ubuntu CentOS Debian Fedora)

	UNAME=$(uname -a | awk 'BEGIN{FS="[_ ]"}{print $1}')
	if echo "${SUPPORT_OS_TYPE[@]}" | grep -w "${UNAME}" &>/dev/null
	then
		if [ "${UNAME}" == "Linux" ]
		then
			if [ -f /usr/bin/lsb_release ]
			then
				OS_DISTRO=$(/usr/bin/lsb_release -a 2>/dev/null| grep "Distributor ID" | awk '{print $3}')
			else
				OS_DISTRO=$(cat /etc/issue |sed -n '1p' | awk '{print $1}')
			fi
			if echo "${SUPPORT_OS_DISTRO[@]}" | grep -w "${OS_DISTRO}" &>/dev/null
			then
				echo "${OS_DISTRO}"
			else
				echo "hyper-tool only support OS_DISTRO [${SUPPORT_OS_TYPE[@]}], doesn't support ${OS_DISTRO} "
				exit 1
			fi
		elif [ "${UNAME}" == "MINGW32" ]
		then
			OS_DISTRO="Windows"
			echo "${OS_DISTRO}"

		fi
	else
		echo "hyper-tool only support OS_TYPE [${SUPPORT_OS_TYPE[@]}], doesn't support ${UNAME} "
		exit 1
	fi
}

###################################################
#show color message
#format: "show_message <message> [color]"
function show_message() {
    local message="$1";
    local color=$2;
    local bold=$3;
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        purple) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    if [ ! -z $bold ]
    then
    	tput bold
	fi
    tput setaf $color;
    echo -e "\n> ${message}";
    tput sgr0;
}

# color
BLACK=`tput setaf 0`
RED=`tput setaf 1`     #error
GREEN=`tput setaf 2`   #info
YELLOW=`tput setaf 3`  #warning
BLUE=`tput setaf 4`
PURPLE=`tput setaf 5`  #prompt
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`
RESET=`tput sgr0`
BOLD=`tput bold `
#example
#echo "Dark : ${BLACK}black ${RED}red ${GREEN}green ${YELLOW}yellow ${BLUE}blue ${PURPLE}purple ${CYAN}cyan ${WHITE}white ${RESET}"
#echo "Ligth: ${BOLD} ${BLACK}black ${RED}red ${GREEN}green ${YELLOW}yellow ${BLUE}blue ${PURPLE}purple ${CYAN}cyan ${WHITE}white ${RESET}"
