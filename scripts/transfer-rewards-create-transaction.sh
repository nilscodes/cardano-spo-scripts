#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: transfer-rewards-create-transaction.sh TTL TARGETADDRESS"
    exit 2
fi

mkdir -p txtmp

TTL=$1
PAY_TO=$2
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentTxData=$(cardano-cli query utxo --address $(cat addr/$PAY_TO.addr) $NETIDENTIFIER | tail -1)
txIn=$(echo $currentTxData | awk '{print $1"#"$2}')
startingAmount=$(echo $currentTxData | awk '{print $3}')
currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
requestedTtl=$(expr $currentSlot + $TTL)

rewardBalance=$(cardano-cli query stake-address-info \
    $NETIDENTIFIER \
    --address $(cat addr/stake.addr) | jq -r ".[0].rewardAccountBalance")
echo "Reward Balance: $rewardBalance"
echo "Balance in target account: $startingAmount"
echo TxIn: $txIn
echo Current Slot $currentSlot
echo Slot TTL $requestedTtl

# Get the current protocol and build the raw transaction without fees
cardano-cli query protocol-parameters $NETIDENTIFIER --out-file protocol.json
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$PAY_TO.addr)+0 \
  --ttl $requestedTtl \
  --fee 0 \
  --withdrawal $(cat addr/stake.addr)+$rewardBalance \
  --out-file txtmp/tx.raw

# Calculate fee via Cardano and calculate remaining balance after fee cost
minFee=$(cardano-cli transaction calculate-min-fee --tx-body-file txtmp/tx.raw $NETIDENTIFIER --protocol-params-file protocol.json --tx-in-count 1 --tx-out-count 1 --witness-count 2 | awk '{print $1}')
remaining=$(expr $startingAmount - $minFee + $rewardBalance)

echo "Balance to be transferred back to me $remaining (including rewards paid out)"
echo "Min Fee $minFee"

# Build final transaction with correct fee, TTL and amount to submit
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$PAY_TO.addr)+$remaining \
  --ttl $requestedTtl \
  --fee $minFee \
  --withdrawal $(cat addr/stake.addr)+$rewardBalance \
  --out-file txtmp/tx.raw



