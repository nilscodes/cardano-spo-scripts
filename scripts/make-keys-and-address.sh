#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: make-keys-and-address.sh ADDRESSNAME"
    exit 2
fi

mkdir -p keys
mkdir -p addr

ADDRESS_NAME=$1
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Generate key for payment address
cardano-cli address key-gen \
  --verification-key-file keys/$ADDRESS_NAME.vkey \
  --signing-key-file keys/$ADDRESS_NAME.skey

# Build a payment address that is connected to the key
cardano-cli address build \
  --payment-verification-key-file keys/$ADDRESS_NAME.vkey \
  --out-file addr/$ADDRESS_NAME.addr \
  $NETIDENTIFIER

# Prevent accidental deletion of address and key files
chmod 400 addr/$ADDRESS_NAME.addr
chmod 400 keys/$ADDRESS_NAME.*