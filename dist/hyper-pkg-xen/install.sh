#/bin/bash

BASEDIR=$(dirname $0)
BINDIR="${BASEDIR}/bin"
BOOTDIR="${BASEDIR}/boot"

TARGET_BIN="/usr/local/bin"
TARGET_CONFIG="/etc/hyper"
TARGET_RUNTIME="/var/lib/hyper"
TARGET_LOG="/var/log/hyper"

export PATH=/usr/local/bin:$PATH

BIOS="TRUE"
if [ $# -ge 1 ] ; then
    if [ "$1" == "--disable-qboot" ] ; then
        BIOS="FALSE"
    fi
fi

command_exist() {
  type "$@" > /dev/null 2>&1
}

require-prog () {
	type $1 > /dev/null
	ret=$?
	if [ $ret -ne 0 ] ; then
	    echo "We need $1 to run Hyper, install $2 or put it into PATH please"
	    exit 1
	fi
}

require-prog qemu-system-x86_64 qemu
require-prog docker "docker.io or docker"

qpver=$(qemu-system-x86_64 --version | awk '{print $4}' | awk -F'.' '{print $1 }')
if [ $qpver -lt 2 ] ; then
    echo "Need Qemu version 2.0 at least."
    exit 1
fi

BASH_C="bash -c"
if [ "${CURRENT_USER}" != "root" ];then
  if (command_exist sudo);then
    BASH_C="sudo -E bash -c"
  fi
fi

read dmajor dminor dfix < <(${BASH_C} "docker version|sed -ne 's/Server version: \([0-9]\{1,\}\)\.\([0-9]\{1,\}\)\.\([0-9]\{1,\}\).*/\1 \2 \3/p'")
if [ $dmajor -lt 1 ]; then 
    echo "Need Docker version 1.5 at least."
    exit 1
fi
if [ $dmajor -eq 1 -a $dminor -lt 5 ]; then 
    echo "Need Docker version 1.5 at least."
    exit 1
fi

sd=$(${BASH_C} "docker info 2>/dev/null |sed -ne 's/Storage Driver: \(.*\)/\1/p'")
if [ $sd != "aufs" -a $sd != "devicemapper" ]; then
    echo "Only docker storage driver aufs and devicemapper are supported"
    exit 1
fi

echo "Now install Hyper..."
mkdir -p ${TARGET_BIN}
mkdir -p ${TARGET_CONFIG}
mkdir -p ${TARGET_RUNTIME}
mkdir -p ${TARGET_LOG}

for f in ${BOOTDIR}/* ; do
    cp $f ${TARGET_RUNTIME}/${f##*/}
done

for f in ${BINDIR}/* ; do
    cp $f ${TARGET_BIN}/${f##*/}
done

cat > ${TARGET_CONFIG}/config << ENDCONFIG
Kernel=${TARGET_RUNTIME}/kernel
Initrd=${TARGET_RUNTIME}/hyper-initrd.img
ENDCONFIG

if [ "$BIOS" == "TRUE" ] ; then
cat >> ${TARGET_CONFIG}/config << ENDADDITION
Bios=${TARGET_RUNTIME}/bios-qboot.bin
Cbfs=${TARGET_RUNTIME}/cbfs-qboot.rom
ENDADDITION
fi

cat << ENDWELCOME
Hyper has been installed! Welcome to the Beta test of Hyper

Have docker daemon run, and 
Try run hyper daemon with
> hyperd [--config=/etc/hyper/config] [-v=1]

Try run hyper command line with
> hyper help
> hyper run -p example/ubuntu.pod
> hyper list

Thank you!
Contact us with Xu Wang <xu@hyper.sh>

if you want to disable qboot, call the installer with flag

    --disable-qboot

or comments out the Bios and Cbfs lines in config file /etc/hyper/config
ENDWELCOME
