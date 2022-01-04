#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: online-register-stake-address.sh TTL PAYFROMADDRESS STAKEPAYMENTADDRESS STAKEADDRESS"
    exit 2
fi

mkdir -p txtmp
mkdir -p certs

TTL=$1
PAY_FROM=$2
PAY_TO_STAKE=$3
SIGN_WITH_STAKE=$4
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentTxData=$(cardano-cli query utxo --address $(cat addr/$PAY_FROM.addr) $NETIDENTIFIER | tail -1)
txIn=$(echo $currentTxData | awk '{print $1"#"$2}')
amountToSend=$(echo $currentTxData | awk '{print $3}')
currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
requestedTtl=$(expr $currentSlot + $TTL)

echo TxIn: $txIn
echo Current Slot $currentSlot
echo Slot TTL $requestedTtl

# Get the current protocol and retrieve the deposit for registering a stake address
cardano-cli query protocol-parameters $NETIDENTIFIER --out-file protocol.json
stakeAddressDeposit=$(jq .stakeAddressDeposit protocol.json)
echo Stake Address Deposit $stakeAddressDeposit

# Build the raw transaction without fees to register the stake address
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$PAY_TO_STAKE.addr)+$amountToSend \
  --ttl $requestedTtl \
  --fee 0 \
  --certificate-file certs/$SIGN_WITH_STAKE.cert \
  --out-file txtmp/tx.raw

# Calculate fee via Cardano and calculate remaining balance after fee cost
minFee=$(cardano-cli transaction calculate-min-fee --tx-body-file txtmp/tx.raw $NETIDENTIFIER --protocol-params-file protocol.json --tx-in-count 1 --tx-out-count 1 --witness-count 2 | awk '{print $1}')
remaining=$(expr $amountToSend - $stakeAddressDeposit - $minFee)

echo Min Fee $minFee
echo Balance to be transferred $remaining

# Build final transaction with correct fee, TTL and amount to submit
cardano-cli transaction build-raw \
  --tx-in $txIn \
  --tx-out $(cat addr/$PAY_TO_STAKE.addr)+$remaining \
  --ttl $requestedTtl \
  --fee $minFee \
  --certificate-file certs/$SIGN_WITH_STAKE.cert \
  --out-file txtmp/tx.raw

echo "Now copy txtmp/tx.raw onto your USB drive and copy it into the respective folder on your offline machine. Then run register-stake-address-offline-sign.sh $PAY_FROM $SIGN_WITH_STAKE"
echo "Copy the resulting txtmp/tx.signed back onto your USB drive and to this machine's txtmp folder."
echo "Then run ./submit-transaction.sh"
