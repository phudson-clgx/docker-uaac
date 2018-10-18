#!/bin/bash
#set -ex

CLIENT_USERNAME=$1
CLIENT_OUTPUT=$()
echo "*****************************!!!CLIENT DETAILS!!!*****************************"
while read line ; do
  printf "%s\n" "$line"
done < <(uaac client get $CLIENT_USERNAME)
echo "*****************************!!!CLIENT DETAILS!!!*****************************"
#echo $CLIENT_OUTPUT
