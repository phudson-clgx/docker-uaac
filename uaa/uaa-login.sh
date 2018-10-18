#!/bin/bash


SCRIPT_NAME=`basename $0`
ID='admin'
#File Config Location
CONFIG_FILE=~/.pcf/uaa.config

OPSMGR_URL_PREPROD=https://opsmgr.preprodapp.cfadm.corelogic.net
OPSMGR_URL_PROD=https://opsmgr.clgxlabs.io
OPSMGR_URL_DR=https://opsmgr.dr.clgxlabs.io

UAA_URL_PREPROD=https://uaa.preprodapp.cf.corelogic.net
UAA_URL_PROD=https://uaa.sys.clgxlabs.io
UAA_URL_DR=https://uaa.sysdr.clgxlabs.io
UAA_URL_LOCAL=https://uaa.local.pcfdev.io

function usage() {
    echo "Usage: $SCRIPT_NAME [preprod|prod|dr|prodio|local]"
    exit 1
}

if [ -z `which jq` ]; then
    echo "jq command is required, but not installed; use 'brew install jq'"
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Missing arguments, exiting ..."
    usage
fi

if [ -z "$1" ] || ([ "$1" != "preprod" ] && [ "$1" != "prod" ] && [ "$1" != "dr" ] && [ "$1" != "prodio" ] && [ "$1" != "local" ] ); then
    echo "Invalid Arguments"
    usage
fi

if [ -r "$CONFIG_FILE" ]; then
    source $CONFIG_FILE
else
    echo "Missing config file: $CONFIG_FILE"
    exit 1
fi

ENVIRONMENT=$1

case $ENVIRONMENT in
    "preprod" )
        OPSMGR_URL="$OPSMGR_URL_PREPROD"
        OPSMGR_PASSWORD="$OPSMGR_PASSWORD_PREPROD"
        UAA_URL="$UAA_URL_PREPROD"
        ;;
    "prod" )
        OPSMGR_URL="$OPSMGR_URL_PROD"
        OPSMGR_PASSWORD="$OPSMGR_PASSWORD_PROD"
        UAA_URL="$UAA_URL_PROD"
        ;;
    "prodio" )
        OPSMGR_URL="$OPSMGR_URL_PRODIO"
        OPSMGR_PASSWORD="$OPSMGR_PASSWORD_PRODIO"
        UAA_URL="$UAA_URL_PRODIO"
        ;;
    "dr" )
        OPSMGR_URL="$OPSMGR_URL_DR"
        OPSMGR_PASSWORD="$OPSMGR_PASSWORD_DR"
        UAA_URL="$UAA_URL_DR"
        ;;
    "local" )
        UAA_URL="$UAA_URL_LOCAL"
        UAA_PASSWORD="$UAA_PASSWORD_LOCAL"
        ;;
esac

if [ $ENVIRONMENT != 'local' ]; then
    uaac target $OPSMGR_URL/uaa --skip-ssl-validation
    uaac token owner get 2>/dev/null <<EOF
opsman

admin
$OPSMGR_PASSWORD
EOF

    # Get the GUID of CF from OpsMgr
    CF_GUID=`uaac curl $OPSMGR_URL/api/v0/deployed/products --insecure | sed -e '1,/RESPONSE BODY:/d' | jq '.[] | select(.type == "cf") .guid' | sed 's/\"//g'`
    # Get the UAA admin client credentials for CF instance
    UAA_PASSWORD=`uaac curl $OPSMGR_URL/api/v0/deployed/products/$CF_GUID/credentials/.uaa.admin_client_credentials --insecure | sed -e '1,/RESPONSE BODY:/d' | jq '.credential.value.password' | sed 's/\"//g'`
fi

uaac target $UAA_URL --skip-ssl-validation
uaac token client get admin -s $UAA_PASSWORD 2>/dev/null
