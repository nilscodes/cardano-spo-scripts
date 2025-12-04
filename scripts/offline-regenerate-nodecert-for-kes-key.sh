#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: offline-regenerate-nodecert-for-kes-key.sh KES_PERIOD"
    exit 2
fi

kesPeriod=$1
COLD_KEY_NAME=cold
VRF_KEY_NAME=vrf
KES_KEY_NAME=kes
NODE_CERTIFICATE_NAME=node-op
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Back up old node-op.cert
curDate=$(date +%Y-%m-%d_%H%M%S)
cp certs/$NODE_CERTIFICATE_NAME.cert certs/${NODE_CERTIFICATE_NAME}_$curDate.cert
echo Created backups of your current operational certificate in certs/${NODE_CERTIFICATE_NAME}_$curDate.cert

# Issue new operational certificate
chmod u+w pool-keys/$COLD_KEY_NAME.counter
chmod u+w certs/$NODE_CERTIFICATE_NAME.cert
cardano-cli node issue-op-cert \
  --kes-verification-key-file pool-keys/$KES_KEY_NAME.vkey \
  --cold-signing-key-file pool-keys/$COLD_KEY_NAME.skey \
  --operational-certificate-issue-counter pool-keys/$COLD_KEY_NAME.counter \
  --kes-period $kesPeriod \
  --out-file certs/$NODE_CERTIFICATE_NAME.cert
chmod u-w pool-keys/$COLD_KEY_NAME.counter
chmod u-w certs/$NODE_CERTIFICATE_NAME.cert

echo "Now copy the updated certs/${NODE_CERTIFICATE_NAME}.cert file onto your block producer node into the certs folder (overwrite the old cert) and restart your node"