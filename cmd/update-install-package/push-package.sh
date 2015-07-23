#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

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

#parameter
FILENAME_LATEST="hyper${SUPPORT_XEN}-latest${S3_MODE}"

S3CMD="awscli" # awscli|s3cmd

WORK_DIR=${BASE_DIR}/../../dist/
mkdir -p ${WORK_DIR}
cd ${WORK_DIR}


check_proxy
export | grep proxy

show_message "local file size:" green
ls -l --color ${UNTAR_DIR}${SUPPORT_XEN}/bin/*
echo
ls -l --color ${UNTAR_DIR}${SUPPORT_XEN}/boot/*

show_message "local file md5 checksum:" green
md5sum ${UNTAR_DIR}${SUPPORT_XEN}/bin/*
echo
md5sum ${UNTAR_DIR}${SUPPORT_XEN}/boot/*

show_message "Check remote version:" green
echo "download http://mirror-hyper-install${S3_MODE}.s3.amazonaws.com/${FILENAME_LATEST}.tgz.md5"
curl -O --progress-bar http://mirror-hyper-install${S3_MODE}.s3.amazonaws.com/${FILENAME_LATEST}.tgz.md5
if [ $? -ne 0 ];then
	echo "Download md5 file failed!"
	exit 1
fi

set -e

cat ${FILENAME_LATEST}.tgz.md5
OLD_VER=$(cat ${FILENAME_LATEST}.tgz.md5 | awk '{print $2}')
OLD_VER=$(echo ${OLD_VER/hyper${SUPPORT_XEN}-v/})
OLD_VER=${OLD_VER/.tgz/}

show_message "Current version:" green
echo ${OLD_VER}

echo -e -n "${LEFT_PAD}${PURPLE}Please input a new version${RESET}(Example: 0.1.2, 'Enter' to cancel):"
read CHOICE
if [[ ! -z ${CHOICE} ]];then
	NEW_VER=${CHOICE}
else
	echo "Cancelled"
	exit 1
fi

echo -e -n "${LEFT_PAD}${PURPLE}Are you sure?${RESET}('y' to continue, 'Enter' to cancel):"
read CHOICE
if [[ -z ${CHOICE} ]] || [[ ${CHOICE} != "y" ]] ;then
	echo "Cancelled"
	exit 1
fi

#parameter
FILENAME_LOCAL="hyper${SUPPORT_XEN}-v${NEW_VER}"

show_message "Remove old install package on the localhost" green
if [ -f ${FILENAME_LOCAL}.tgz -o -f ${FILENAME_LOCAL}.tgz.md5 ];then
\rm ${FILENAME_LOCAL}.tgz* -rf
fi
show_message "Start re-tar install package..." green
GZIP="-9" tar czvf ${FILENAME_LOCAL}.tgz ${UNTAR_DIR}${SUPPORT_XEN}
md5sum ${FILENAME_LOCAL}.tgz > ${FILENAME_LOCAL}.tgz.md5
echo "tar done"

show_message "show new install package:" green
ls -l --color ${FILENAME_LOCAL}.tgz*
echo "------------------------------------------------------"


echo -e -n "${LEFT_PAD}${PURPLE}Which s3 cli do you want to use?${RESET}('a' for awscli, 's' for s3cmd,'Enter' to cancel):"
read CHOICE
case "${CHOICE}" in
	a ) S3CMD="awscli";;
	s ) S3CMD="s3cmd";;
	*)
		echo "Cancelled"
		exit 1 ;;
esac

show_message "Start upload new install package to s3..." green
if [ ${S3CMD} == "awscli" ];then
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 cp ${FILENAME_LOCAL}.tgz.md5 s3://mirror-hyper-install${S3_MODE}/${FILENAME_LOCAL}.tgz.md5 --acl=public-read"
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 cp ${FILENAME_LOCAL}.tgz s3://mirror-hyper-install${S3_MODE}/${FILENAME_LOCAL}.tgz --acl=public-read"
else
	run_cmd "s3cmd --progress put -r ${FILENAME_LOCAL}.tgz* s3://mirror-hyper-install${S3_MODE}/ --acl-public"
fi
echo "push done!"

show_message "Backup old version..." green
OLD_VER=${OLD_VER}${SUPPORT_XEN}
\rm -rf ${OLD_VER}
mkdir -p ${OLD_VER}
echo "$(date +'%F %T')" > ${OLD_VER}/readme.md
if [ ${S3CMD} == "awscli" ];then
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 sync ${OLD_VER} s3://mirror-hyper-install${S3_MODE}/${OLD_VER}/ --acl=public-read"
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 s3://mirror-hyper-install${S3_MODE}/${OLD_VER}/ --acl=public-read"
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz s3://mirror-hyper-install${S3_MODE}/${OLD_VER}/ --acl=public-read"
else
	run_cmd "s3cmd --progress put -r ${OLD_VER} s3://mirror-hyper-install${S3_MODE}/ --acl-public"
	run_cmd "s3cmd --progress cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 s3://mirror-hyper-install${S3_MODE}/${OLD_VER}/ --acl-public"
	run_cmd "s3cmd --progress cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz s3://mirror-hyper-install${S3_MODE}/${OLD_VER}/ --acl-public"
fi
\rm -rf ${OLD_VER}
echo "backup done!"

show_message "Start replace new version..." green
if [ ${S3CMD} == "awscli" ];then
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 mv s3://mirror-hyper-install${S3_MODE}/${FILENAME_LOCAL}.tgz.md5 s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 --acl=public-read"
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --region=ap-northeast-1 mv s3://mirror-hyper-install${S3_MODE}/${FILENAME_LOCAL}.tgz s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz --acl=public-read"
else
	run_cmd "s3cmd --progress mv s3://mirror-hyper-install${S3_MODE}/${FILENAME_LOCAL}.tgz.md5 s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 --acl-public"
	run_cmd "s3cmd --progress mv s3://mirror-hyper-install${S3_MODE}/${FILENAME_LOCAL}.tgz s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz --acl-public"
fi
echo "replace new version done."

show_message "Start Copy mirror-hyper-install${S3_MODE} to hyper-install${S3_MODE}..." green
if [ ${S3CMD} == "awscli" ];then
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --source-region=ap-northeast-1 --region=us-east-1 cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 s3://hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 --acl=public-read"
	run_cmd "aws s3 --profile ${HYPER_PROFILE} --source-region=ap-northeast-1 --region=us-east-1 cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz s3://hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz --acl=public-read"
else
	run_cmd "s3cmd --progress cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 s3://hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz.md5 --acl-public"
	run_cmd "s3cmd --progress cp s3://mirror-hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz s3://hyper-install${S3_MODE}/${FILENAME_LATEST}.tgz --acl-public"
fi
echo "copy mirror done."

echo "=== compare packages size ============================================================"

show_message "Show local packages" green
ls -l --color ${FILENAME_LOCAL}.tgz

show_message "Show remote packages" green
echo "-------------------------------------------------"
echo "http://hyper-install${S3_MODE}.s3.amazonaws.com"
aws --profile hyper s3 ls hyper-install${S3_MODE}
echo "-------------------------------------------------"
echo "http://mirror-hyper-install${S3_MODE}.s3.amazonaws.com"
aws --profile hyper s3 ls mirror-hyper-install${S3_MODE}
echo "-------------------------------------------------"

echo "=== compare packages md5 checksum ============================================================"

show_message "Show local md5 checksum" green
cat ${FILENAME_LOCAL}.tgz.md5

show_message "Show remote md5 checksum" green
echo "http://hyper-install${S3_MODE}.s3.amazonaws.com/${FILENAME_LATEST}.tgz.md5"
curl -sSL http://hyper-install${S3_MODE}.s3.amazonaws.com/${FILENAME_LATEST}.tgz.md5
echo "http://mirror-hyper-install${S3_MODE}.s3.amazonaws.com/${FILENAME_LATEST}.tgz.md5"
curl -sSL http://mirror-hyper-install${S3_MODE}.s3.amazonaws.com/${FILENAME_LATEST}.tgz.md5

set +e