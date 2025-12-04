#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: unregister-stake-pool.sh TTL RETIRE_IN_EPOCHS STAKE_PAYMENT"
    exit 2
fi

mkdir -p txtmp

TTL=$1
RETIRE_IN_EPOCHS=$2
STAKE_PAYMENT=$3
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentTxData=$(cardano-cli query utxo --address $(cat addr/$STAKE_PAYMENT.addr) $NETIDENTIFIER | tail -1)
txIn=$(echo $currentTxData | awk '{print $1"#"$2}')
amountToSend=$(echo $currentTxData | awk '{print $3}')

currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
requestedTtl=$(expr $currentSlot + $TTL)
currentEpoch=$(cardano-cli query tip $NETIDENTIFIER | jq .epoch)
retireInEpoch=$(expr $currentEpoch + $RETIRE_IN_EPOCHS)

echo "Current amount in stake address (last transaction) is $amountToSend"
echo Current Epoch is $currentEpoch
echo Retiring in Epoch $retireInEpoch

# Create deregistration certificate
cardano-cli stake-pool deregistration-certificate \
--cold-verification-key-file pool-keys/cold.vkey \
--epoch $retireInEpoch \
--out-file certs/pool-deregistration.cert

# Build the raw transaction without fees to unregister the stake pool and pay back the remaining funds to ourselves
cardano-cli transaction build-raw \
--tx-in $txIn \
--tx-out $(cat addr/$STAKE_PAYMENT.addr)+$amountToSend \
--ttl $requestedTtl \
--fee 0 \
--certificate-file certs/pool-deregistration.cert \
--out-file txtmp/tx.raw

# Calculate fee via Cardano and calculate remaining balance after fee cost
minFee=$(cardano-cli transaction calculate-min-fee --tx-body-file txtmp/tx.raw $NETIDENTIFIER --protocol-params-file protocol.json --tx-in-count 1 --tx-out-count 1 --witness-count 2 | awk '{print $1}')
remaining=$(expr $amountToSend - $minFee)

echo Min Fee $minFee
echo Balance to be transferred back to stake payment address $remaining

# Build final transaction with correct fee, TTL and amount to submit
cardano-cli transaction build-raw \
--tx-in $txIn \
--tx-out $(cat addr/$STAKE_PAYMENT.addr)+$remaining \
--ttl $requestedTtl \
--fee $minFee \
--certificate-file certs/pool-deregistration.cert \
--out-file txtmp/tx.raw

# Sign Transaction with stake payment address and cold key
cardano-cli transaction sign \
    --tx-body-file txtmp/tx.raw \
    --signing-key-file keys/$STAKE_PAYMENT.skey \
    --signing-key-file pool-keys/cold.skey \
    $NETIDENTIFIER \
    --out-file txtmp/tx.signed

# Submit Transaction
cardano-cli transaction submit \
  --tx-file txtmp/tx.signed \
  $NETIDENTIFIER