#!/bin/bash
#set -ex

CLIENT_USERNAME=$1
NEW_CLIENT_GRANTS=$2
NEW_CLIENT_AUTHORITIES=$3
#echo $CLIENT_USERNAME
CLIENT_SCOPE=""
CLIENT_GRANT=""
CLIENT_AUTHORITIES=""
#CLIENT_OUTPUT=$(uaac client get $CLIENT_USERNAME | sed 's/\n/test/'| awk '/scope|authorized_grant_types|authorities/{print $0}'  |sed 's/  //')
#CLIENT_SCOPE=($)
#echo $CLIENT_OUTPUT
while read line ; do
  if [[ $line =~ "scope:" ]]; then
    CLIENT_SCOPE=$line

  elif [[ $line =~ "authorized_grant_types:" ]]; then
    CLIENT_GRANT=$line

  elif [[ $line =~ "authorities:" ]]; then
    CLIENT_AUTHORITIES=$line
  fi
done < <(uaac client get $CLIENT_USERNAME | awk '/scope|authorized_grant_types|authorities/{print $0}' | sed 's/  //')
CLIENT_SCOPE=$(echo "${CLIENT_SCOPE}"| sed 's/scope: //' | sed 's/ /,/g')
CLIENT_GRANT=$(echo "${CLIENT_GRANT}"| sed 's/authorized_grant_types: //' | sed 's/ /,/g')
CLIENT_AUTHORITIES=$(echo "${CLIENT_AUTHORITIES}"| sed 's/authorities: //' | sed 's/ /,/g')
#echo $CLIENT_SCOPE
#echo $CLIENT_GRANT
#echo $CLIENT_AUTHORITIES
if [ "$NEW_CLIENT_GRANTS" != "0" ] ; then
    NEW_CLIENT_GRANTS="${CLIENT_GRANT},${NEW_CLIENT_GRANTS}"
else
    NEW_CLIENT_GRANTS="${CLIENT_GRANT}"
fi
if [ "$NEW_CLIENT_AUTHORITIES" != "0" ] ; then
    NEW_CLIENT_AUTHORITIES="${CLIENT_AUTHORITIES},${NEW_CLIENT_AUTHORITIES}"
else
    NEW_CLIENT_AUTHORITIES="${CLIENT_AUTHORITIES}"
fi


UAAC_CMD="uaac client update ${CLIENT_USERNAME} --scope ${CLIENT_SCOPE} --authorized_grant_types ${NEW_CLIENT_GRANTS} --authorities ${NEW_CLIENT_AUTHORITIES}"
#echo $UAAC_CMD
eval $UAAC_CMD
