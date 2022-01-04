#!/bin/bash

NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)
NETNAME=$(cat $HOME/cardano-node-conf/netname)
KES_KEY_NAME=kes

# Get the starting KES period
slotNo=$(cardano-cli query tip $NETIDENTIFIER | jq -r '.slot')
slotsPerKESPeriod=$(jq .slotsPerKESPeriod $HOME/cardano-node-conf/$NETNAME-shelley-genesis.json)
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
startKesPeriod=${kesPeriod}
echo Write down the startKesPeriod for use on your air-gapped offline node: ${startKesPeriod}

# Back up old KES keys
curDate=$(date +%Y-%m-%d_%H%M%S)
cp pool-keys/$KES_KEY_NAME.vkey pool-keys/${KES_KEY_NAME}_$curDate.vkey
cp pool-keys/$KES_KEY_NAME.skey pool-keys/${KES_KEY_NAME}_$curDate.skey
echo Created backups of your current KES keys in pool-keys/${KES_KEY_NAME}_$curDate.vkey/skey

# Create New KES keys
cardano-cli node key-gen-KES \
  --verification-key-file pool-keys/$KES_KEY_NAME.vkey \
  --signing-key-file pool-keys/$KES_KEY_NAME.skey
echo Created new KES keys in pool-keys/${KES_KEY_NAME}.vkey/skey
echo "Please copy the .vkey file onto a removable media and transfer it to your offline machine into the pool-keys folder and run ./offline-regenerate-nodecert-for-kes-key.sh ${kesPeriod}"