#!/bin/sh
#set -ex

SCRIPT_NAME=`basename $0`
SCRIPT_HOME=`dirname $0`

# Directory where clp-shared-components project resides
REPO_DIR=$SCRIPT_HOME/.${SCRIPT_NAME}
CSC=clp-shared-components
CCC=clp-cloud-config

# File locations
JAR_LOCATION=$REPO_DIR/$CSC/keystore-cipher-maker/build/libs
CONFIG_FILE=~/.pcf/config-server-cipher.config

function printUsageAndExit() {
  echo "Usage : $SCRIPT_NAME [encrypt|decrypt] [prod|preprod] STRING"
  exit 1
}

# Permform some validation on input arguments
if [ $# -ne 3 ]; then
  echo "Missing arguments, exiting.."
  printUsageAndExit
fi

if [ -z "$1" ] || ([ "$1" != "encrypt" ] && [ "$1" != "decrypt" ]); then
  echo "Invalid action specified"
  printUsageAndExit
fi

if [ -z "$2" ] || ([ "$2" != "prod" ] && [ "$2" != "preprod" ]); then
  echo "Invalid environment specified"
  printUsageAndExit
fi

# Check for configuration file
if [ -r "$CONFIG_FILE" ]; then
  source $CONFIG_FILE
else
  echo "Missing config file: $CONFIG_FILE"
  exit 1
fi

ACTION=$1
ENVIRONMENT=$2
KEYSTORE_FILE="$REPO_DIR/$CCC/keystores/$ENVIRONMENT/keystore.jks"
if [ "$ENVIRONMENT" == "prod" ]; then
  KEYSTORE_ALIAS="$PROD_KEYSTORE_ALIAS"
  KEYSTORE_SECRET="$PROD_KEYSTORE_SECRET"
  KEYSTORE_PASSWORD="$PROD_KEYSTORE_PASSWORD"
else
  KEYSTORE_ALIAS="$PREPROD_KEYSTORE_ALIAS"
  KEYSTORE_SECRET="$PREPROD_KEYSTORE_SECRET"
  KEYSTORE_PASSWORD="$PREPROD_KEYSTORE_PASSWORD"
fi
JAR_LOCATION=$REPO_DIR/$CSC/keystore-cipher-maker/build/libs
JAR_FILE=
if [ -d $JAR_LOCATION ]; then
  JAR_FILE=`find $JAR_LOCATION/*.jar|head -1`
fi
java -jar $JAR_FILE $ACTION $KEYSTORE_FILE $KEYSTORE_PASSWORD $KEYSTORE_ALIAS $KEYSTORE_SECRET $3
