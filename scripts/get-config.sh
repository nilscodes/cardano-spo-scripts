#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: get-config.sh mainnet|preview|preprod"
    exit 2
fi

if [ "$1" = "mainnet" ]; then
    wget https://book.play.dev.cardano.org/environments/mainnet/config.json -O $HOME/cardano-node-conf/config.json
    wget https://book.play.dev.cardano.org/environments/mainnet/byron-genesis.json -O $HOME/cardano-node-conf/byron-genesis.json
    wget https://book.play.dev.cardano.org/environments/mainnet/shelley-genesis.json -O $HOME/cardano-node-conf/shelley-genesis.json
    wget https://book.play.dev.cardano.org/environments/mainnet/alonzo-genesis.json -O $HOME/cardano-node-conf/alonzo-genesis.json
    wget https://book.play.dev.cardano.org/environments/mainnet/conway-genesis.json -O $HOME/cardano-node-conf/conway-genesis.json
    wget https://book.play.dev.cardano.org/environments/mainnet/checkpoints.json -O $HOME/cardano-node-conf/checkpoints.json
    wget https://book.play.dev.cardano.org/environments/mainnet/peer-snapshot.json -O $HOME/cardano-node-conf/peer-snapshot.json
    wget https://book.play.dev.cardano.org/environments/mainnet/topology.json -O $HOME/cardano-node-conf/topology.json
elif [ "$1" = "preprod" ]; then
    wget https://book.play.dev.cardano.org/environments/preprod/config.json -O $HOME/cardano-node-conf/config.json
    wget https://book.play.dev.cardano.org/environments/preprod/byron-genesis.json -O $HOME/cardano-node-conf/byron-genesis.json
    wget https://book.play.dev.cardano.org/environments/preprod/shelley-genesis.json -O $HOME/cardano-node-conf/shelley-genesis.json
    wget https://book.play.dev.cardano.org/environments/preprod/alonzo-genesis.json -O $HOME/cardano-node-conf/alonzo-genesis.json
    wget https://book.play.dev.cardano.org/environments/preprod/conway-genesis.json -O $HOME/cardano-node-conf/conway-genesis.json
    wget https://book.play.dev.cardano.org/environments/preprod/checkpoints.json -O $HOME/cardano-node-conf/checkpoints.json
    wget https://book.play.dev.cardano.org/environments/preprod/peer-snapshot.json -O $HOME/cardano-node-conf/peer-snapshot.json
    wget https://book.play.dev.cardano.org/environments/preprod/topology.json -O $HOME/cardano-node-conf/topology.json
else
    wget https://book.play.dev.cardano.org/environments/preview/config.json -O $HOME/cardano-node-conf/config.json
    wget https://book.play.dev.cardano.org/environments/preview/byron-genesis.json -O $HOME/cardano-node-conf/byron-genesis.json
    wget https://book.play.dev.cardano.org/environments/preview/shelley-genesis.json -O $HOME/cardano-node-conf/shelley-genesis.json
    wget https://book.play.dev.cardano.org/environments/preview/alonzo-genesis.json -O $HOME/cardano-node-conf/alonzo-genesis.json
    wget https://book.play.dev.cardano.org/environments/preview/conway-genesis.json -O $HOME/cardano-node-conf/conway-genesis.json
    wget https://book.play.dev.cardano.org/environments/preview/checkpoints.json -O $HOME/cardano-node-conf/checkpoints.json
    wget https://book.play.dev.cardano.org/environments/preview/peer-snapshot.json -O $HOME/cardano-node-conf/peer-snapshot.json
    wget https://book.play.dev.cardano.org/environments/preview/topology.json -O $HOME/cardano-node-conf/topology.json
fi