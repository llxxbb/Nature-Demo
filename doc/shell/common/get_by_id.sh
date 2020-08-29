#!/bin/bash

# input parameter:
#   id : $1
#   meta: $2
#   state_version: $3

echo "1-------------""$1"
id=$(echo "obase=16;ibase=10;$1" | bc)
echo "2-------------""$id"

JSON_STRING=$( jq -n \
                  --arg a "${id,,}" \
                  --arg b "$2" \
                  --argjson sta_ver "$3" \
                  '{"id":$a, "meta":$b ,"state_version":$sta_ver}' )

curl -H "Content-type: application/json" -X POST \
     -d"$JSON_STRING" http://localhost:8080/get_by_id | jq '.Ok'
