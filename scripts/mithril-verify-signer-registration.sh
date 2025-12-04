#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: mithril-verify-signer-registration.sh PARTY_ID"
    echo "Example: mithril-verify-signer-registration.sh pool1xyz..."
    exit 2
fi

PARTY_ID=$1
AGGREGATOR_ENDPOINT="https://aggregator.release-mainnet.api.mithril.network/aggregator"

CURRENT_EPOCH=$(curl -s "$AGGREGATOR_ENDPOINT/epoch-settings" -H 'accept: application/json' | jq -r '.epoch')
SIGNERS_REGISTERED_RESPONSE=$(curl -s "$AGGREGATOR_ENDPOINT/signers/registered/$CURRENT_EPOCH" -H 'accept: application/json')

if echo "$SIGNERS_REGISTERED_RESPONSE" | grep -q "$PARTY_ID"; then
    echo ">> Congrats, your signer node is registered!"
else
    echo ">> Oops, your signer node is not registered. Party ID not found among the signers registered at epoch ${CURRENT_EPOCH}."
fi
