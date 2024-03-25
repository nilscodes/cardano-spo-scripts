#!/bin/bash

if [ "$#" -ne 0 ]; then
    echo "Usage: update-node-binary.sh"
    exit 2
fi

echo - Updating cardano node to currently built version

sudo systemctl stop cardano-node

cd $HOME/src/cardano-node
cp -p $(find dist-newstyle/ -name "cardano-node" -type f | head -n 1) $HOME/.local/bin/
cp -p $(find dist-newstyle/ -name "cardano-cli" -type f | head -n 1) $HOME/.local/bin/
cd $HOME

sudo systemctl start cardano-node

CARDANO_NODE_VERSION_INSTALLED=$(cardano-node --version)
CARDANO_CLI_VERSION_INSTALLED=$(cardano-cli --version)
echo - Successfully installed cardano-node $CARDANO_NODE_VERSION_INSTALLED and cardano-cli $CARDANO_CLI_VERSION_INSTALLED
