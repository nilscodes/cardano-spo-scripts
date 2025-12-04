#!/bin/bash

if [ "$#" -ne 0 ]; then
    echo "Usage: update-node-binary.sh"
    exit 2
fi

echo - Updating cardano node to currently built version

sudo systemctl stop cardano-node

cd $HOME/src/cardano-node
cp -p $(find dist-newstyle/ -name "cardano-node" -type f | head -n 1) $HOME/.local/bin/
cp -p $(./scripts/bin-path.sh cardano-cli) $HOME/.local/bin/
cp -p $(./scripts/bin-path.sh cardano-tracer) $HOME/.local/bin/
cd $HOME

sudo systemctl start cardano-node

CARDANO_NODE_VERSION_INSTALLED=$(cardano-node --version)
CARDANO_CLI_VERSION_INSTALLED=$(cardano-cli --version)
CARDANO_TRACER_VERSION_INSTALLED=$(cardano-tracer --version)
echo - Successfully installed cardano-node $CARDANO_NODE_VERSION_INSTALLED, cardano-cli $CARDANO_CLI_VERSION_INSTALLED, and cardano-tracer $CARDANO_TRACER_VERSION_INSTALLED
