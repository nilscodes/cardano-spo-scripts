#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: build-merge-transaction.sh TTL ADDRESS_TO_MERGE_FROM TARGET_ADDRESS"
    exit 2
fi

mkdir -p txtmp

TTL=$1
PAY_FROM=$2
PAY_TO=$3
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentTxData1=$(cardano-cli query utxo --address $(cat addr/$PAY_FROM.addr) $NETIDENTIFIER | tail -2 | head -1)
txIn1=$(echo $currentTxData1 | awk '{print $1"#"$2}')
startingAmount1=$(echo $currentTxData1 | awk '{print $3}')

currentTxData2=$(cardano-cli query utxo --address $(cat addr/$PAY_FROM.addr) $NETIDENTIFIER | tail -1)
txIn2=$(echo $currentTxData2 | awk '{print $1"#"$2}')
startingAmount2=$(echo $currentTxData2 | awk '{print $3}')

totalSend=$(expr $startingAmount1 + $startingAmount2)
currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
requestedTtl=$(expr $currentSlot + $TTL)

echo TxIn1: $txIn1
echo TxIn2: $txIn2
echo Balance to be transferred to recipient $totalSend
echo Current Slot $currentSlot
echo Slot TTL $requestedTtl

# Get the current protocol and build the raw transaction without fees
cardano-cli query protocol-parameters $NETIDENTIFIER --out-file protocol.json
cardano-cli transaction build-raw \
  --tx-in $txIn1 \
  --tx-in $txIn2 \
  --tx-out $(cat addr/$PAY_TO.addr)+$totalSend \
  --ttl $requestedTtl \
  --fee 0 \
  --out-file txtmp/tx.raw

# Calculate fee via Cardano and calculate remaining balance after fee cost
minFee=$(cardano-cli transaction calculate-min-fee --tx-body-file txtmp/tx.raw $NETIDENTIFIER --protocol-params-file protocol.json --tx-in-count 2 --tx-out-count 1 --witness-count 1 | awk '{print $1}')
remaining=$(expr $totalSend - $minFee)

echo Final Balance to be transferred $remaining
echo Min Fee $minFee

# Build final transaction with correct fee, TTL and amount to submit
cardano-cli transaction build-raw \
  --tx-in $txIn1 \
  --tx-in $txIn2 \
  --tx-out $(cat addr/$PAY_TO.addr)+$remaining \
  --ttl $requestedTtl \
  --fee $minFee \
  --out-file txtmp/tx.raw

# Sign Transaction
cardano-cli transaction sign \
  --tx-body-file txtmp/tx.raw \
  --signing-key-file keys/$PAY_FROM.skey \
  $NETIDENTIFIER \
  --out-file txtmp/tx.signed

# Submit Transaction
cardano-cli transaction submit \
  --tx-file txtmp/tx.signed \
  $NETIDENTIFIER

