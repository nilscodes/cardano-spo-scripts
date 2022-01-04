#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: query.sh ADDRESS"
    exit 2
fi

ADDRESS=$1
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Query the given address
cardano-cli query stake-address-info --address $(cat addr/$ADDRESS.addr) $NETIDENTIFIER
