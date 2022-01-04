#!/bin/bash

if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
    echo "Usage: set-net.sh mainnet|testnet [TESTNET_MAGIC_ID]"
    exit 2
fi

NET_TYPE=$1
if [ "$NET_TYPE" = "testnet" ] && [ "$#" -ne 2 ]; then
    echo "Usage: set-net.sh mainnet|testnet [TESTNET_MAGIC_ID]"
    exit 2
fi

mkdir -p $HOME/cardano-node-conf

echo $NET_TYPE > $HOME/cardano-node-conf/netname

if [ "$#" -eq 2 ]; then
    TESTNET_MAGIC_ID=$2
    echo --testnet-magic $TESTNET_MAGIC_ID > $HOME/cardano-node-conf/cardano-cli-net-param
else
    echo --mainnet > $HOME/cardano-node-conf/cardano-cli-net-param
fi

./get-config.sh $NET_TYPE