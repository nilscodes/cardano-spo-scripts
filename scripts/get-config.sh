#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: get-config.sh mainnet|testnet"
    exit 2
fi

if [ "$1" = "mainnet" ]; then
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json -O $HOME/cardano-node-conf/mainnet-config.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-byron-genesis.json -O $HOME/cardano-node-conf/mainnet-byron-genesis.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-shelley-genesis.json -O $HOME/cardano-node-conf/mainnet-shelley-genesis.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-alonzo-genesis.json -O $HOME/cardano-node-conf/mainnet-alonzo-genesis.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-topology.json -O $HOME/cardano-node-conf/mainnet-topology.json
    
else
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-config.json -O $HOME/cardano-node-conf/testnet-config.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-byron-genesis.json -O $HOME/cardano-node-conf/testnet-byron-genesis.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-shelley-genesis.json -O $HOME/cardano-node-conf/testnet-shelley-genesis.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-alonzo-genesis.json -O $HOME/cardano-node-conf/testnet-alonzo-genesis.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-topology.json -O $HOME/cardano-node-conf/testnet-topology.json
fi