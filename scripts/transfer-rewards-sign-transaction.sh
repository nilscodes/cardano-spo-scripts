#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: transfer-rewards-sign-transaction.sh TARGETADDRESS"
    exit 2
fi

PAY_TO=$1
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Sign Transaction with payment address signing key and stake signing key
cardano-cli transaction sign \
  --tx-body-file txtmp/tx.raw \
  --signing-key-file keys/$PAY_TO.skey \
  --signing-key-file keys/stake.skey \
  $NETIDENTIFIER \
  --out-file txtmp/tx.signed