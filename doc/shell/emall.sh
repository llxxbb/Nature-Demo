#!/bin/bash

# This shell to simulate the business system client to communicate with Nature.

# generate order-----------------------------------
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

path=$(dirname "$0")

# submit order to Nature
rtn1=$("$path"/common/input.sh "B:sale/order:1" "$instance")

# cam be reentrant----------------------------------------
rtn2=$("$path"/common/input.sh "B:sale/order:1" "$instance")

if [ "$rtn1" != "$rtn2" ]; then
  echo "should be equal"
  exit 1
fi

# wait state instance generated----------------------------

"$path"/common/get_by_id_wait.sh "$rtn1" "B:sale/orderState:1" 1


