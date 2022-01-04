#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: build-move-specific-transaction.sh TTL TARGETADDRESS"
    exit 2
fi

mkdir -p txtmp

TTL=$1
PAY_TO_ADDRESS=$2
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

txInCount=3
txIn1=2906cdbabb08fbd78ac7b720a4fb1f643d1579185bfc13d68f627da3108e6ef5#0
txIn2=36d8223e255af0ea213753d39c44d5a8e192e01b6f7aa45aff8abf40ea82c7ac#0
txIn3=52b9e8e5535e4ca551c525aeb4ab0ba13b844e89d2c230576b215a8f1a49c08c#0
amountToSend=117503000000
currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
requestedTtl=$(expr $currentSlot + $TTL)
echo Current Slot $currentSlot
echo Slot TTL $requestedTtl

# Get the current protocol and build the raw transaction without fees
cardano-cli query protocol-parameters $NETIDENTIFIER --out-file protocol.json
cardano-cli transaction build-raw \
  --tx-in $txIn1 \
  --tx-in $txIn2 \
  --tx-in $txIn3 \
  --tx-out $PAY_TO_ADDRESS+$amountToSend \
  --ttl $requestedTtl \
  --fee 0 \
  --out-file txtmp/tx.raw

# Calculate fee via Cardano and calculate remaining balance after fee cost
minFee=$(cardano-cli transaction calculate-min-fee --tx-body-file txtmp/tx.raw $NETIDENTIFIER --protocol-params-file protocol.json --tx-in-count $txInCount --tx-out-count 1 --witness-count 1 | awk '{print $1}')
remaining=$(expr $amountToSend - $minFee)

echo Min Fee $minFee
echo Balance to be transferred $remaining

# Build final transaction with correct fee, TTL and amount to submit
cardano-cli transaction build-raw \
  --tx-in $txIn1 \
  --tx-in $txIn2 \
  --tx-in $txIn3 \
  --tx-out $PAY_TO_ADDRESS+$remaining \
  --ttl $requestedTtl \
  --fee $minFee \
  --out-file txtmp/tx.raw