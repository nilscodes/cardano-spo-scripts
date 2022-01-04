#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: build-move-transaction.sh TTL AMOUNT_TO_SEND SOURCEADDRESS TARGETADDRESS"
    exit 2
fi

mkdir -p txtmp

TTL=$1
AMOUNT_TO_SEND=$2
PAY_FROM=$3
PAY_TO=$4
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentTxData=$(cardano-cli query utxo --address $(cat addr/$PAY_FROM.addr) $NETIDENTIFIER | tail -1)
txIn=$(echo $currentTxData | awk '{print $1"#"$2}')
startingAmount=$(echo $currentTxData | awk '{print $3}')
myRemaining=$(expr $startingAmount - $AMOUNT_TO_SEND)
currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
requestedTtl=$(expr $currentSlot + $TTL)

echo TxIn: $txIn
echo Amount to Start with: $startingAmount
echo Balance to be transferred to recipient $AMOUNT_TO_SEND
echo Current Slot $currentSlot
echo Slot TTL $requestedTtl

# Get the current protocol and build the raw transaction without fees
cardano-cli query protocol-parameters $NETIDENTIFIER --out-file protocol.json
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$PAY_TO.addr)+$AMOUNT_TO_SEND \
  --tx-out $(cat addr/$PAY_FROM.addr)+$myRemaining \
  --ttl $requestedTtl \
  --fee 0 \
  --out-file txtmp/tx.raw

# Calculate fee via Cardano and calculate remaining balance after fee cost
minFee=$(cardano-cli transaction calculate-min-fee --tx-body-file txtmp/tx.raw $NETIDENTIFIER --protocol-params-file protocol.json --tx-in-count 1 --tx-out-count 2 --witness-count 1 | awk '{print $1}')
remaining=$(expr $myRemaining - $minFee)

echo Balance to be transferred back to me $remaining
echo Min Fee $minFee

# Build final transaction with correct fee, TTL and amount to submit
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$PAY_TO.addr)+$AMOUNT_TO_SEND \
  --tx-out $(cat addr/$PAY_FROM.addr)+$remaining \
  --ttl $requestedTtl \
  --fee $minFee \
  --out-file txtmp/tx.raw

# Sign Transaction with payment address signing key
# cardano-cli transaction sign \
#  --tx-body-file txtmp/tx.raw \
#  --signing-key-file keys/$PAY_FROM.skey \
#  $NETIDENTIFIER \
#  --out-file txtmp/tx.signed

# Submit Transaction
# cardano-cli transaction submit \
#  --tx-file txtmp/tx.signed \
#  $NETIDENTIFIER

