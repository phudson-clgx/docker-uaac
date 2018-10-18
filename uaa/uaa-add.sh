#!/bin/bash
#set -ex

CLIENT_USERNAME=$1
NEW_CLIENT_GRANTS=$2
NEW_CLIENT_AUTHORITIES=$3
NEW_CLIENT_SCOPE=$4
PCF_ENV=$5
RAN_PWD=$(openssl rand -base64 32 | sha256sum | base64 | head -c 12 ; echo)
UAAC_CMD="uaac client add ${CLIENT_USERNAME} --scope ${NEW_CLIENT_SCOPE} --authorized_grant_types ${NEW_CLIENT_GRANTS} --authorities ${NEW_CLIENT_AUTHORITIES} -s ${RAN_PWD}"

echo $UAAC_CMD
eval $UAAC_CMD
echo "*****************************!!!ENCRYPTED CLIENT SECRET!!!*****************************"
#echo "####DEBUG##### --- $RAN_PWD"
bash /root/config-server-cipher.sh encrypt $PCF_ENV $RAN_PWD
echo "*****************************!!!ENCRYPTED CLIENT SECRET!!!*****************************"
