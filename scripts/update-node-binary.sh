#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: update-node-binary.sh GHC_VERSION CARDANO_NODE_VERSION"
    exit 2
fi

CARDANO_NODE_VERSION_TO_UPDATE_TO=$2
GHC_VERSION_TO_BUILD_WITH=$1

echo - Updating cardano node to version $CARDANO_NODE_VERSION_TO_UPDATE_TO

sudo systemctl stop cardano-node

cd $HOME/src/cardano-node
cp -p dist-newstyle/build/x86_64-linux/ghc-$GHC_VERSION_TO_BUILD_WITH/cardano-node-$CARDANO_NODE_VERSION_TO_UPDATE_TO/x/cardano-node/noopt/build/cardano-node/cardano-node $HOME/.local/bin/
cp -p dist-newstyle/build/x86_64-linux/ghc-$GHC_VERSION_TO_BUILD_WITH/cardano-cli-$CARDANO_NODE_VERSION_TO_UPDATE_TO/x/cardano-cli/noopt/build/cardano-cli/cardano-cli $HOME/.local/bin/
cd $HOME

sudo systemctl start cardano-node

CARDANO_VERSION_INSTALLED=$(cardano-cli --version)
echo - Successfully installed cardano-node $CARDANO_VERSION_INSTALLED
