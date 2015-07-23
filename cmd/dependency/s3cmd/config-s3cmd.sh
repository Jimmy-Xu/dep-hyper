#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "The following command will be executed:" blue
echo "  s3cmd --configure"
cat <<COMMENT
Sample
  Access Key: ****************HQTQ
  Secret Key: ****************bOGr
  Default Region: ap-northeast-1
  Encryption password:
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0
COMMENT

pause
echo "(Just press 'Enter' if no change)"
s3cmd --configure

is_s3cmd_configured