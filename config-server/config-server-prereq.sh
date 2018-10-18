#!/bin/sh
set -ex

SCRIPT_NAME=`basename $0`
SCRIPT_HOME=`dirname $0`

# Directory where clp-shared-components project resides
REPO_DIR=/root/.config-server-cipher.sh
CSC=clp-shared-components
CCC=clp-cloud-config

# File locations
JAR_LOCATION=$REPO_DIR/$CSC/keystore-cipher-maker/build/libs
CONFIG_FILE=~/.pcf/config-server-cipher.config

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

# Make sure the base repository directory exists
if [ ! -d $REPO_DIR ]; then mkdir -p $REPO_DIR; fi

# Check that repos exist and are updated
for REPO_NAME in $CSC $CCC
do
  if [ ! -d "$REPO_DIR/$REPO_NAME/.git" ]; then
    git clone --depth 1 --branch master git@github.com:corelogic/$REPO_NAME.git $REPO_DIR/$REPO_NAME
  else
    # Checks for updates every 2 days
    if [ -n "`find $REPO_DIR/$REPO_NAME/.git/FETCH_HEAD -mtime 2 2>/dev/null`" ]; then
      echo "Checking for updates in $REPO_NAME... "
      pushd $REPO_DIR/$REPO_NAME > /dev/null
      if [ "`git ls-remote origin -h refs/heads/master|cut -f1`" != "`git rev-parse @`" ]; then
        echo "Updating... "
        git pull --no-tags
        echo "Done"
      else
        echo "Up to date."
      fi
      popd > /dev/null
    fi
  fi
done

# Check to see if keystore-cipher-maker jar has been built
JAR_FILE=
if [ -d $JAR_LOCATION ]; then
  JAR_FILE=`find $JAR_LOCATION/*.jar|head -1`
fi

if [ -z $JAR_FILE ]; then
  echo "Compiling keystore-cipher-maker..."
  pushd $REPO_DIR/$CSC/keystore-cipher-maker > /dev/null
  ./gradlew clean build
  popd > /dev/null
fi
