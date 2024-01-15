#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: offline-make-stake-and-payment-addresses.sh STAKEADDRESS STAKEPAYMENTADDRESS"
    exit 2
fi

mkdir -p keys
mkdir -p addr

STAKE=$1
STAKE_PAYMENT=$2
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Generate key for payment address
cardano-cli address key-gen \
  --verification-key-file keys/$STAKE_PAYMENT.vkey \
  --signing-key-file keys/$STAKE_PAYMENT.skey

# Generate key for stake address
cardano-cli stake-address key-gen \
  --verification-key-file keys/$STAKE.vkey \
  --signing-key-file keys/$STAKE.skey

# Build stake address 
cardano-cli stake-address build \
  --stake-verification-key-file keys/$STAKE.vkey \
  --out-file addr/$STAKE.addr \
  $NETIDENTIFIER

# Build a payment address that is connected to the stake address
cardano-cli address build \
  --stake-verification-key-file keys/$STAKE.vkey \
  --payment-verification-key-file keys/$STAKE_PAYMENT.vkey \
  --out-file addr/$STAKE_PAYMENT.addr \
  $NETIDENTIFIER

# Prevent accidental deletion of address and key files
chmod 400 addr/$STAKE.addr
chmod 400 addr/$STAKE_PAYMENT.addr
chmod 400 keys/$STAKE.*
chmod 400 keys/$STAKE_PAYMENT.*

echo "Copy all files from the addr folder to the same location on your core node. Do NOT copy any of the files from other folders."
echo "Then run ./offline-create-stake-registration-cert.sh $STAKE on this machine"