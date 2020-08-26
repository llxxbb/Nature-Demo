#!/bin/bash

# This shell to simulate the business system client to communicate with Nature.

## generate order-----------------------------------
instance='{
  "user_id":123,
  "price":1000,
  "items":[
    {
      "item":{
        "id":1,
        "name":"phone",
        "price":800
      },
      "num":1
    },
    {
      "item":{
        "id":2,
        "name":"battery",
        "price":100
      },
      "num":1
    }
  ],
  "address":"a.b.c"
}'

myMeta="B:/sale/order:1"

## submit order to Nature

JSON_STRING=$( jq -n \
                  --arg meta "$myMeta" \
                  --arg content "$instance" \
                  '{"data":{"meta": $meta, "content": $content}}' )

echo  "$JSON_STRING"

url="http://localhost:8080/input"

curl -H "Content-type: application/json" -X POST \
     -d"$JSON_STRING" $url

