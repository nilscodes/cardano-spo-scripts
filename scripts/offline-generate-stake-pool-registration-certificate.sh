#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: generate-stake-pool-registration-certificate.sh METADATAURL"
    exit 2
fi

COLD_KEY_NAME=cold
VRF_KEY_NAME=vrf
STAKE=stake
METADATA_URL=$1
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

pledgeLovelace=65000000000
fixedCostLovelace=340000000
marginPercent=0.03
metadataHash=$(cat metadata/stake-pool-metadata.hash)
relay1Ip=$(cat topology/relay1-ip.txt)
relay1Dns=$(cat topology/relay1-dns.txt)
relay1Port=$(cat topology/relay1-port.txt)
relay2Ip=$(cat topology/relay2-ip.txt)
relay2Dns=$(cat topology/relay2-dns.txt)
relay2Port=$(cat topology/relay2-port.txt)

echo Pledging $pledgeLovelace Lovelace
echo Costs will be $fixedCostLovelace fixed Lovelace and $marginPercent margin
echo Using metadata from $METADATA_URL

if [ "$relay1Dns" != "" ]; then
  relayInfo="  --single-host-pool-relay $relay1Dns --pool-relay-port $relay1Port"
  echo First Relay node registered is $relay1Dns:$relay1Port
else
  relayInfo="  --pool-relay-ipv4 $relay1Ip --pool-relay-port $relay1Port"
  echo First Relay node registered is $relay1Ip:$relay1Port
fi

if [ "$relay2Dns" != "" ]; then
  relayInfo="$relayInfo --single-host-pool-relay $relay2Dns --pool-relay-port $relay2Port"
  echo Second Relay node registered is $relay2Dns:$relay2Port
elif [ "$relay2Ip" != "" ]; then
  relayInfo="$relayInfo --pool-relay-ipv4 $relay2Ip --pool-relay-port $relay2Port"
  echo Second Relay node registered is $relay2Ip:$relay2Port
fi

# Create stake pool registration certificate
cardano-cli stake-pool registration-certificate \
  --cold-verification-key-file pool-keys/$COLD_KEY_NAME.vkey \
  --vrf-verification-key-file pool-keys/$VRF_KEY_NAME.vkey \
  --pool-pledge $pledgeLovelace \
  --pool-cost $fixedCostLovelace \
  --pool-margin $marginPercent \
  --pool-reward-account-verification-key-file keys/$STAKE.vkey \
  --pool-owner-stake-verification-key-file keys/$STAKE.vkey \
  $NETIDENTIFIER \
  $relayInfo \
  --metadata-url $METADATA_URL \
  --metadata-hash $metadataHash \
  --out-file certs/pool-registration.cert

# Create stake pool delegation certificate
cardano-cli stake-address delegation-certificate \
  --stake-verification-key-file keys/$STAKE.vkey \
  --cold-verification-key-file pool-keys/$COLD_KEY_NAME.vkey \
  --out-file certs/pool-delegation.cert

# Prevent accidental deletion of cert files
chmod 400 certs/pool-registration.cert
chmod 400 certs/pool-delegation.cert