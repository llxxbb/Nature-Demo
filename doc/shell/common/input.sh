#!/bin/bash

# input parameter:
#   meta : $1
#   content: $2

JSON_STRING=$( jq -n \
                  --arg meta "$1" \
                  --arg content "$2" \
                  '{"data":{"meta": $meta, "content": $content}}' )

rtn=$(curl -H "Content-type: application/json" -X POST \
     -d"$JSON_STRING" http://localhost:8080/input)
echo "${rtn//[^0-9]/}"