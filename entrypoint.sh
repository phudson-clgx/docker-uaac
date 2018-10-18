#!/bin/bash
#bash /root/config-server-cipher.sh encrypt preprod test
#set -ex
function printUsageAndExit() {
  echo "Example Docker Command : docker run -it -e PCFENV=\"[preprod|prod]\" -e ACTION=\"[add|update]\" -e CLIENT=\"tax-recoveries-adapter-client\" -e SCOPE=\"clauth-account-service.application\" -e GRANTS=\"refresh_token,password,client_credentials\" -e AUTHORITIES=\"uaa.resource,clauth-account-service.application\" --rm docker-uaac-add [encrypt|decrypt] [prod|preprod] STRING"
  exit 1
}
if [ -z "$PCFENV" ] || [ -z "$ACTION" ]; then
  echo "PCF Environment or action not provided"
  printUsageAndExit
fi
if [ "$PCFENV" == "preprod" ]; then
    /root/uaa-login.sh preprod 2>/dev/null
    if [ "$ACTION" == "update" ]; then
      if [ -z "$CLIENT" ] ; then
          echo "Client name not given"
          printUsageAndExit
      else
        if [ -z "$GRANTS" ]; then
          GRANTS="0"
        fi
        if [ -z "$AUTHORITIES" ]; then
          AUTHORITIES="0"
        fi
        /root/uaa-update.sh $CLIENT $GRANTS $AUTHORITIES
      fi
    fi
    if [ "$ACTION" == "add" ]; then
      if [ -z "$CLIENT" ] || [ -z "$SCOPE" ] || [ -z "$GRANTS" ] || [ -z "$AUTHORITIES" ] ; then
          echo "Action ADD given, but no additional grants or authorities provided"
          printUsageAndExit
      else
        /root/uaa-add.sh $CLIENT $GRANTS $AUTHORITIES $SCOPE $PCFENV
      fi
    fi
    if [ "$ACTION" == "get" ]; then
        /root/uaa-get.sh $CLIENT
    fi
fi
#tail -f /dev/null
