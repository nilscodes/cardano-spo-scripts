#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: catalyst-offline-sign-register-transaction.sh STAKEPAYMENTADDRESS"
    exit 2
fi

STAKE_PAYMENT=$1
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Create a TX witness file for the transaction signed with the payment address signing key
cardano-cli transaction witness \
  $NETIDENTIFIER \
  --tx-body-file txtmp/tx.raw \
  --signing-key-file keys/$STAKE_PAYMENT.skey \
  --out-file txtmp/tx.witness

# Assemble the TX with the witness file
cardano-cli transaction assemble \
  --tx-body-file txtmp/tx.raw \
  --witness-file txtmp/tx.witness \
  --out-file txtmp/tx.signed

echo "Copy txtmp/tx.signed to your relay and run ./submit-transaction.sh"