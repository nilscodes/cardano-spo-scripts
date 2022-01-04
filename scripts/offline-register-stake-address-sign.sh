#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: offline-register-stake-address-sign.sh PAYFROMADDRESS STAKEADDRESS"
    exit 2
fi

PAY_FROM=$1
SIGN_WITH_STAKE=$2
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Sign Transaction with both payment address and stake signing keys 
cardano-cli transaction sign \
  --tx-body-file txtmp/tx.raw \
  --signing-key-file keys/$PAY_FROM.skey \
  --signing-key-file keys/$SIGN_WITH_STAKE.skey \
  $NETIDENTIFIER \
  --out-file txtmp/tx.signed

