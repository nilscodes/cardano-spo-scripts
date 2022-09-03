#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: build-node-code.sh CABAL_VERSION GHC_VERSION CARDANO_NODE_VERSION"
    echo "Latest current compatible versions are 3.6.2.0 for CABAL_VERSION, 8.10.7 for GHC_VERSION and 1.35.3 for CARDANO_NODE_VERSION"
    exit 2
fi

CABAL_VERSION_TO_INSTALL=$1
GHC_VERSION_TO_INSTALL=$2
CARDANO_NODE_VERSION_TO_INSTALL=$3

#    ___              _                         __          _         _____           _        _ _ 
#   / __\__ _ _ __ __| | __ _ _ __   ___     /\ \ \___   __| | ___    \_   \_ __  ___| |_ __ _| | |
#  / /  / _` | '__/ _` |/ _` | '_ \ / _ \   /  \/ / _ \ / _` |/ _ \    / /\/ '_ \/ __| __/ _` | | |
# / /__| (_| | | | (_| | (_| | | | | (_) | / /\  / (_) | (_| |  __/ /\/ /_ | | | \__ \ || (_| | | |
# \____/\__,_|_|  \__,_|\__,_|_| |_|\___/  \_\ \/ \___/ \__,_|\___| \____/ |_| |_|___/\__\__,_|_|_|                                                                                                 

# Install node libraries
sudo apt-get update -y
sudo apt-get install build-essential pkg-config libffi-dev libgmp-dev -y
sudo apt-get install libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev -y
sudo apt-get install make g++ tmux git jq wget libncursesw5 libtool autoconf -y
sudo apt-get install -y autotools-dev autoconf automake

# Install Cabal
cd $HOME
echo - Installing Cabal version $CABAL_VERSION_TO_INSTALL
wget https://downloads.haskell.org/~cabal/cabal-install-$CABAL_VERSION_TO_INSTALL/cabal-install-$CABAL_VERSION_TO_INSTALL-x86_64-linux-alpine-static.tar.xz
tar -xf cabal-install-$CABAL_VERSION_TO_INSTALL-x86_64-linux-alpine-static.tar.xz
rm cabal-install-$CABAL_VERSION_TO_INSTALL-x86_64-linux-alpine-static.tar.xz cabal.sig
mkdir -p $HOME/.local/bin
mv cabal $HOME/.local/bin/

echo >> $HOME/.bashrc
echo \# From Cardano Node Script build-node-code.sh >> $HOME/.bashrc
echo export PATH="$HOME/.local/bin:\$PATH" >> $HOME/.bashrc
echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> $HOME/.bashrc
echo export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" >> $HOME/.bashrc

export PATH="$HOME/.local/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

$HOME/.local/bin/cabal update
CABAL_VERSION=$($HOME/.local/bin/cabal --version)
echo - Installed Cabal version $CABAL_VERSION

# Install GHC
echo - Installing GHC version $GHC_VERSION_TO_INSTALL
wget https://downloads.haskell.org/ghc/$GHC_VERSION_TO_INSTALL/ghc-$GHC_VERSION_TO_INSTALL-x86_64-deb9-linux.tar.xz
tar -xf ghc-$GHC_VERSION_TO_INSTALL-x86_64-deb9-linux.tar.xz
rm $HOME/ghc-$GHC_VERSION_TO_INSTALL-x86_64-deb9-linux.tar.xz
cd $HOME/ghc-$GHC_VERSION_TO_INSTALL
./configure
sudo make install
GHC_VERSION=$(ghc --version)
cd $HOME
echo - Installed GHC version $GHC_VERSION

# Install LibSodium from Git and build it
echo - Installing LibSodium
mkdir -p $HOME/src
cd $HOME/src
git clone https://github.com/input-output-hk/libsodium
cd $HOME/src/libsodium
git checkout 66f017f1
$HOME/src/libsodium/autogen.sh
$HOME/src/libsodium/configure
make
sudo make install
cd $HOME
rm -rf $HOME/src
echo - Installed LibSodium

# Install libsecp256k1
echo - Installing libsecp256k1
mkdir -p $HOME/src
cd $HOME/src
git clone https://github.com/bitcoin-core/secp256k1
cd $HOME/src/secp256k1
git checkout ac83be33
$HOME/src/secp256k1/autogen.sh
$HOME/src/secp256k1/configure --enable-module-schnorrsig --enable-experimental
make
make check
sudo make install
sudo ldconfig
cd $HOME
rm -rf $HOME/src
echo - Installed libsecp256k1

# Install cardano-node from Git and build it
echo - Installing cardano node version $CARDANO_NODE_VERSION_TO_INSTALL
mkdir -p $HOME/src
cd $HOME/src
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node/
git fetch --all --recurse-submodules --tags
git checkout tags/$CARDANO_NODE_VERSION_TO_INSTALL
$HOME/.local/bin/cabal configure -O0 --with-compiler=ghc-$GHC_VERSION_TO_INSTALL
echo "package cardano-crypto-praos" >>  cabal.project.local
echo "  flags: -external-libsodium-vrf" >>  cabal.project.local

$HOME/.local/bin/cabal clean
$HOME/.local/bin/cabal update
$HOME/.local/bin/cabal build all

cp -p dist-newstyle/build/x86_64-linux/ghc-$GHC_VERSION_TO_INSTALL/cardano-node-$CARDANO_NODE_VERSION_TO_INSTALL/x/cardano-node/noopt/build/cardano-node/cardano-node $HOME/.local/bin/
cp -p dist-newstyle/build/x86_64-linux/ghc-$GHC_VERSION_TO_INSTALL/cardano-cli-$CARDANO_NODE_VERSION_TO_INSTALL/x/cardano-cli/noopt/build/cardano-cli/cardano-cli $HOME/.local/bin/
cd $HOME

CARDANO_VERSION_INSTALLED=$(cardano-cli --version)
echo - Successfully installed cardano-node $CARDANO_VERSION_INSTALLED
