#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

WORK_DIR=${BASE_DIR}/../../dist

case $1 in
dev) S3_MODE="-dev";;
live) S3_MODE="";;
*) exit 1
;;
esac

case "$2" in
--without-xen) SUPPORT_XEN="";;
*) SUPPORT_XEN="-xen";;
esac

mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

check_proxy
export | grep proxy

FILENAME_LATEST="hyper${SUPPORT_XEN}-latest${S3_MODE}"

echo "-------------------------------------------"
show_message "Start download current install package from s3..." green
#run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 ./${FILENAME_LATEST}.tgz.md5"
#run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz ./${FILENAME_LATEST}.tgz"
run_cmd "curl -O --progress-bar http://mirror-hyper-install${S3_MODE}.s3.amazonaws.com/${FILENAME_LATEST}.tgz.md5"
run_cmd "curl -O --progress-bar http://mirror-hyper-install${S3_MODE}.s3.amazonaws.com/${FILENAME_LATEST}.tgz"
echo "pull done!"
echo "-------------------------------------------"

show_message "Start untar install package from ${FILENAME_LATEST}.tgz..." green
if [ -d ${UNTAR_DIR}${SUPPORT_XEN} ];then
	\rm ${UNTAR_DIR}${SUPPORT_XEN} -rf
fi
tar xzvf ${FILENAME_LATEST}.tgz
TGZ_MD5=$(md5sum ${FILENAME_LATEST}.tgz | awk '{print $1}')
CHK_MD5=$(cat ${FILENAME_LATEST}.tgz.md5 | awk '{print $1}')
if [ "${TGZ_MD5}" != "${CHK_MD5}" ];then
	show_message "Can not get correct ${FILENAME_LATEST}.tgz!" red
	exit 1
fi
#\rm ${FILENAME_LATEST}.tgz -rf
echo "untar done!"
echo
show_message "Pulled version: " green
cat ${FILENAME_LATEST}.tgz.md5
echo "-------------------------------------------"
show_message "Install package already untar to [ ${WORK_DIR}/hyper-pkg${SUPPORT_XEN}/ ] dir, please update new file in this dir." green bold