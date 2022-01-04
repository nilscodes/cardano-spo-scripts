#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: build-move-all-transaction-sign.sh SOURCEADDRESS"
    exit 2
fi

mkdir -p txtmp

PAY_FROM=$1
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Sign Transaction with payment address signing key
cardano-cli transaction sign \
  --tx-body-file txtmp/tx.raw \
  --signing-key-file keys/$PAY_FROM.skey \
  $NETIDENTIFIER \
  --out-file txtmp/tx.signed

