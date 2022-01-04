#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: build-stake-pool-registration-transaction.sh TTL"
    exit 2
fi

mkdir -p txtmp

TTL=$1
STAKE_PAYMENT=stake-payment
STAKE=stake
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentTxData=$(cardano-cli query utxo --address $(cat addr/$STAKE_PAYMENT.addr) $NETIDENTIFIER | tail -1)
txIn=$(echo $currentTxData | awk '{print $1"#"$2}')
amountInAddress=$(echo $currentTxData | awk '{print $3}')
currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
requestedTtl=$(expr $currentSlot + $TTL)

echo TxIn: $txIn
echo Current Slot $currentSlot
echo Slot TTL $requestedTtl
echo Total amount in $STAKE_PAYMENT.addr is $amountInAddress

# Get the current protocol and retrieve the deposit for registering a stake address
cardano-cli query protocol-parameters $NETIDENTIFIER --out-file protocol.json
stakePoolDeposit=$(jq .stakePoolDeposit protocol.json)
echo Stake Pool Deposit to be paid $stakePoolDeposit

# Build the raw transaction without fees to register the stake pool and pay back the remaining funds to ourselves
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$STAKE_PAYMENT.addr)+0 \
  --ttl $requestedTtl \
  --fee 0 \
  --certificate-file certs/pool-registration.cert \
  --certificate-file certs/pool-delegation.cert \
  --out-file txtmp/tx.raw

# Calculate fee via Cardano and calculate remaining balance after fee cost
minFee=$(cardano-cli transaction calculate-min-fee --tx-body-file txtmp/tx.raw $NETIDENTIFIER --protocol-params-file protocol.json --tx-in-count 1 --tx-out-count 1 --witness-count 3 | awk '{print $1}')
remaining=$(expr $amountInAddress - $stakePoolDeposit - $minFee)

echo Min Fee $minFee
echo Balance to be transferred back to stake payment address $remaining

# Build final transaction with correct fee, TTL and amount to submit
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$STAKE_PAYMENT.addr)+$remaining \
  --ttl $requestedTtl \
  --fee $minFee \
  --certificate-file certs/pool-registration.cert \
  --certificate-file certs/pool-delegation.cert \
  --out-file txtmp/tx.raw

echo "Copy txtmp/tx.raw to your offline machine and run ./offline-build-stake-pool-registration-transaction.sh"