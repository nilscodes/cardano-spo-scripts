#!/bin/bash

# Cardano network
export CARDANO_NETWORK=mainnet

# Aggregator API endpoint URL
export AGGREGATOR_ENDPOINT=https://aggregator.release-mainnet.api.mithril.network/aggregator

# Genesis verification key
GENESIS_VERIFICATION_KEY=$(wget -q -O - https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/release-mainnet/genesis.vkey)

# Ancillary verification key
ANCILLARY_VERIFICATION_KEY=$(wget -q -O - https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/release-mainnet/ancillary.vkey)

# Digest of the latest produced cardano db snapshot for convenience of the demo
SNAPSHOT_DIGEST=latest

mithril-client cardano-db download --include-ancillary --genesis-verification-key $GENESIS_VERIFICATION_KEY --ancillary-verification-key $ANCILLARY_VERIFICATION_KEY $SNAPSHOT_DIGEST