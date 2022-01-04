#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: offline-create-stake-registration-cert.sh STAKEADDRESS"
    exit 2
fi

mkdir -p certs

SIGN_WITH_STAKE=$1

# Generate a registration certificate
cardano-cli stake-address registration-certificate \
  --stake-verification-key-file keys/$SIGN_WITH_STAKE.vkey \
  --out-file certs/$SIGN_WITH_STAKE.cert

# Prevent accidental deletion of cert files
chmod 400 certs/$SIGN_WITH_STAKE.cert

echo "Copy certs/$SIGN_WITH_STAKE.cert onto your USB drive and transfer it into the respective folder on your core node"
echo "On the core node, run ./register-stake-address.sh"