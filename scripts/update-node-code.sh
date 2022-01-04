#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: update-node-code.sh GHC_VERSION CARDANO_NODE_VERSION"
    exit 2
fi

CARDANO_NODE_VERSION_TO_UPDATE_TO=$2
GHC_VERSION_TO_BUILD_WITH=$1
CURRENT_CARDANO_VERSION=$(cardano-cli --version)

echo - Updating cardano node to version $CARDANO_NODE_VERSION_TO_UPDATE_TO

cd $HOME/src/cardano-node
git fetch --all --recurse-submodules --tags
git checkout tags/$CARDANO_NODE_VERSION_TO_UPDATE_TO
git reset --hard
$HOME/.local/bin/cabal configure --with-compiler=ghc-$GHC_VERSION_TO_BUILD_WITH
echo "package cardano-crypto-praos" >>  cabal.project.local
echo "  flags: -external-libsodium-vrf" >>  cabal.project.local

$HOME/.local/bin/cabal clean
$HOME/.local/bin/cabal update
$HOME/.local/bin/cabal build all

mkdir -p $HOME/binary-backup
cp $HOME/.local/bin/cardano-* $HOME/binary-backup

echo "Backup of your existing cardano binaries ($CURRENT_CARDANO_VERSION) was made to $HOME/binary-backup"
echo "Stop your node, then copy over your new cardano-cli and cardano-node binaries with update-node-binary.sh"