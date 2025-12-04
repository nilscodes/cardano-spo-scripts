#!/bin/bash

mkdir -p pool-keys
mkdir -p certs

COLD_KEY_NAME=cold
VRF_KEY_NAME=vrf
KES_KEY_NAME=kes
NODE_CERTIFICATE_NAME=node-op
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Create cold keys and cold counter
cardano-cli node key-gen \
  --cold-verification-key-file pool-keys/$COLD_KEY_NAME.vkey \
  --cold-signing-key-file pool-keys/$COLD_KEY_NAME.skey \
  --operational-certificate-issue-counter-file pool-keys/$COLD_KEY_NAME.counter

# Create VRF keys
cardano-cli node key-gen-VRF \
  --verification-key-file pool-keys/$VRF_KEY_NAME.vkey \
  --signing-key-file pool-keys/$VRF_KEY_NAME.skey

# Create KES keys
cardano-cli node key-gen-KES \
  --verification-key-file pool-keys/$KES_KEY_NAME.vkey \
  --signing-key-file pool-keys/$KES_KEY_NAME.skey

slotsPerKESPeriod=$(jq .slotsPerKESPeriod $HOME/cardano-node-conf/shelley-genesis.json)
echo "Run the following script on the online node and enter the value here: ./get-current-slot.sh"
read -p 'Current slot is: ' currentSlot
kesPeriod=$(expr $currentSlot / $slotsPerKESPeriod)
echo "Slots per KES Period: $slotsPerKESPeriod"
echo "Current Slot: $currentSlot"
echo "KES period: $kesPeriod"

cardano-cli node issue-op-cert \
  --kes-verification-key-file pool-keys/$KES_KEY_NAME.vkey \
  --cold-signing-key-file pool-keys/$COLD_KEY_NAME.skey \
  --operational-certificate-issue-counter pool-keys/$COLD_KEY_NAME.counter \
  --kes-period $kesPeriod \
  --out-file certs/$NODE_CERTIFICATE_NAME.cert

# Prevent accidental deletion of key and cert files
chmod 400 pool-keys/$COLD_KEY_NAME.*
chmod 400 pool-keys/$VRF_KEY_NAME.*
chmod 400 pool-keys/$KES_KEY_NAME.*
chmod 400 certs/$NODE_CERTIFICATE_NAME.cert