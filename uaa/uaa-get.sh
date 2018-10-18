#!/bin/bash
#set -ex

CLIENT_USERNAME=$1
CLIENT_OUTPUT=$()
while read line ; do
  printf "%s\n" "$line"
done < <(uaac client get $CLIENT_USERNAME)
#echo $CLIENT_OUTPUT
