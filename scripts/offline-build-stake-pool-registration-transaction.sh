#!/bin/bash

# Script to sign the stake pool registration transaction with all the necessary signing keys. Only to be run on your offline machine.

STAKE_PAYMENT=stake-payment
STAKE=stake
COLD_KEY_NAME=cold
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Sign Transaction with both payment address and stake signing keys 
cardano-cli transaction sign \
  --tx-body-file txtmp/tx.raw \
  --signing-key-file keys/$STAKE_PAYMENT.skey \
  --signing-key-file keys/$STAKE.skey \
  --signing-key-file pool-keys/$COLD_KEY_NAME.skey \
  $NETIDENTIFIER \
  --out-file txtmp/tx.signed

# Verify registration by retrieving the pool ID
poolId=$(cardano-cli stake-pool id --cold-verification-key-file pool-keys/cold.vkey --output-format "hex")
echo "Copy transaction from txtmp/tx.signed to your online relay node and run ./submit-transaction.sh"
echo "Pool ID in HEX format is $poolId"
echo "Run command cardano-cli query ledger-state $NETIDENTIFIER | grep publicKey | grep $poolId to verify pool is registered after submitting the transaction"
