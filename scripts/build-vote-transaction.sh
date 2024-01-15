#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: build-vote-transaction.sh POOL_ID PAY_FROM ANSWERFILE"
    exit 2
fi

mkdir -p txtmp

POOL_ID=$1
PAY_FROM=$2
ANSWERFILE=$3
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentTxData=$(cardano-cli query utxo --address $(cat addr/$PAY_FROM.addr) $NETIDENTIFIER | tail -1)
txIn=$(echo $currentTxData | awk '{print $1"#"$2}')

cardano-cli transaction build \
    --babbage-era \
    --cardano-mode \
    --mainnet \
    --tx-in $txIn \
    --change-address $(cat addr/$PAY_FROM.addr) \
    --metadata-json-file $ANSWERFILE \
    --json-metadata-detailed-schema \
    --required-signer-hash $POOL_ID \
  --out-file txtmp/tx.raw