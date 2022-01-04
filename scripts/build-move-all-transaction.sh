#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: build-move-all-transaction.sh TTL SOURCEADDRESS TARGETADDRESS"
    exit 2
fi

mkdir -p txtmp

TTL=$1
PAY_FROM=$2
PAY_TO=$3
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentTxData=$(cardano-cli query utxo --address $(cat addr/$PAY_FROM.addr) $NETIDENTIFIER | tail -1)
txIn=$(echo $currentTxData | awk '{print $1"#"$2}')
amountToSend=$(echo $currentTxData | awk '{print $3}')
currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
requestedTtl=$(expr $currentSlot + $TTL)

echo TxIn: $txIn
echo Current Slot $currentSlot
echo Slot TTL $requestedTtl

# Get the current protocol and build the raw transaction without fees
cardano-cli query protocol-parameters $NETIDENTIFIER --out-file protocol.json
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$PAY_TO.addr)+$amountToSend \
  --ttl $requestedTtl \
  --fee 0 \
  --out-file txtmp/tx.raw

# Calculate fee via Cardano and calculate remaining balance after fee cost
minFee=$(cardano-cli transaction calculate-min-fee --tx-body-file txtmp/tx.raw $NETIDENTIFIER --protocol-params-file protocol.json --tx-in-count 1 --tx-out-count 1 --witness-count 1 | awk '{print $1}')
remaining=$(expr $amountToSend - $minFee)

echo Min Fee $minFee
echo Balance to be transferred $remaining

# Build final transaction with correct fee, TTL and amount to submit
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$PAY_TO.addr)+$remaining \
  --ttl $requestedTtl \
  --fee $minFee \
  --out-file txtmp/tx.raw

# Sign Transaction with payment address signing key
cardano-cli transaction sign \
  --tx-body-file txtmp/tx.raw \
  --signing-key-file keys/$PAY_FROM.skey \
  $NETIDENTIFIER \
  --out-file txtmp/tx.signed

# Submit Transaction
cardano-cli transaction submit \
  --tx-file txtmp/tx.signed \
  $NETIDENTIFIER

