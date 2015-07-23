#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "The following command will be executed:" blue
echo "  aws configure --profile hyper"
cat <<COMMENT

Sample configuration:
	AWS Access Key ID : ****************HQTQ
	AWS Secret Access Key : ****************bOGr
	Default region name : ap-northeast-1
	Default output format : json

COMMENT


pause
echo "(Just press 'Enter' if no change)"
aws configure --profile hyper

is_awscli_configured