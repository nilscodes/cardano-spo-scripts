#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: mithril-verify-signer-signature.sh POOL_ID"
    echo "Example: mithril-verify-signer-signature.sh pool1xyz..."
    exit 2
fi

PARTY_ID=$1
AGGREGATOR_ENDPOINT="https://aggregator.release-mainnet.api.mithril.network/aggregator"

CERTIFICATES_RESPONSE=$(curl -s "$AGGREGATOR_ENDPOINT/certificates" -H 'accept: application/json')
CERTIFICATES_COUNT=$(echo "$CERTIFICATES_RESPONSE" | jq '. | length')

echo "$CERTIFICATES_RESPONSE" | jq -r '.[] | .hash' | while read -r HASH; do
    RESPONSE=$(curl -s "$AGGREGATOR_ENDPOINT/certificate/$HASH" -H 'accept: application/json')
    SIGNER_COUNT=$(echo "$RESPONSE" | jq '.metadata.signers | length')
    for (( i=0; i < SIGNER_COUNT; i++ )); do
        PARTY_ID_RESPONSE=$(echo "$RESPONSE" | jq -r ".metadata.signers[$i].party_id")
        if [[ "$PARTY_ID_RESPONSE" == "$PARTY_ID" ]]; then
            echo ">> Congrats, you have signed this certificate: $AGGREGATOR_ENDPOINT/certificate/$HASH !"
            exit 1
        fi
    done
done

echo ">> Oops, your party id was not found in the last ${CERTIFICATES_COUNT} certificates. Please try again later."
