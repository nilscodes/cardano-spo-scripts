#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: catalyst-build-register-transaction.sh STAKEPAYMENTADDRESS UTXO_IN"
    exit 2
fi

mkdir -p txtmp

STAKE_PAYMENT=$1
# A UTXO available on the pledge address to pay for the transaction fee in the form of tx-hash#tx-index
UTXO_IN=$2
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)
CATALYST_ACC_NAME=catalyst_reg_pledge_acc_0

# Build the raw transaction with change address for returning excess funds from the TX fees, and the Catalyst registration certificate as metadata
cardano-cli transaction build \
  $NETIDENTIFIER \
  --tx-in $UTXO_IN \
  --change-address $(cat addr/$STAKE_PAYMENT.addr) \
  --metadata-cbor-file catalyst/$CATALYST_ACC_NAME.cbor \
  --out-file txtmp/tx.raw

echo "Copy txtmp/tx.raw to your offline machine and run ./catalyst-offline-sign-register-transaction.sh"