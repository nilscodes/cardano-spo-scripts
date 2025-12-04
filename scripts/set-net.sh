#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: set-net.sh mainnet|preprod|preview"
    exit 2
fi

NET_TYPE=$1
mkdir -p "$HOME/cardano-node-conf"

case "$NET_TYPE" in
    mainnet)
        echo --mainnet > "$HOME/cardano-node-conf/cardano-cli-net-param"
        ;;
    preprod)
        # Cardano pre-production testnet
        echo --testnet-magic 1 > "$HOME/cardano-node-conf/cardano-cli-net-param"
        ;;
    preview)
        # Cardano preview testnet
        echo --testnet-magic 2 > "$HOME/cardano-node-conf/cardano-cli-net-param"
        ;;
    *)
        echo "Error: unsupported network '$NET_TYPE'"
        echo "Usage: set-net.sh mainnet|preprod|preview"
        exit 2
        ;;
esac

./get-config.sh "$NET_TYPE"
