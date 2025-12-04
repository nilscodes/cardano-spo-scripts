#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: build-node-code.sh CABAL_VERSION GHC_VERSION CARDANO_NODE_VERSION"
    echo "Latest current compatible versions are 3.12.1.0 for CABAL_VERSION, 9.6.7 for GHC_VERSION and 10.5.1 for CARDANO_NODE_VERSION"
    exit 2
fi

CABAL_VERSION_TO_INSTALL=$1
GHC_VERSION_TO_INSTALL=$2
CARDANO_NODE_VERSION_TO_INSTALL=$3

# This may need adjusting from time to time
BLST_VERSION_TAG="v0.3.14"
SECP256K1_VERSION_TAG="v0.3.2"
LIBSODIUM_REV="dbb48cce5429cb6585c9034f002568964f1ce567"

#    ___              _                         __          _         _____           _        _ _ 
#   / __\__ _ _ __ __| | __ _ _ __   ___     /\ \ \___   __| | ___    \_   \_ __  ___| |_ __ _| | |
#  / /  / _` | '__/ _` |/ _` | '_ \ / _ \   /  \/ / _ \ / _` |/ _ \    / /\/ '_ \/ __| __/ _` | | |
# / /__| (_| | | | (_| | (_| | | | | (_) | / /\  / (_) | (_| |  __/ /\/ /_ | | | \__ \ || (_| | | |
# \____/\__,_|_|  \__,_|\__,_|_| |_|\___/  \_\ \/ \___/ \__,_|\___| \____/ |_| |_|___/\__\__,_|_|_|                                                                                                 

sudo apt-get update -y
# Install dependencies for GHCup
sudo apt-get install build-essential libffi-dev libffi8ubuntu1 libgmp-dev libgmp10 libncurses-dev -y
# Install other packages required to run the node
sudo apt-get install pkg-config libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev -y
sudo apt-get install make g++ tmux git jq wget curl libtool autoconf -y
sudo apt-get install autotools-dev autoconf automake -y

# Install GHCup
if [ ! -f "$HOME/.ghcup/bin/ghcup" ]; then
  echo "- Installing ghcup..."
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org \
    | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 sh
fi

# Force ghcup to use only the stable/vanilla channel
ghcup config set url-source https://downloads.haskell.org/ghcup/ghcup-metadata/vanilla.yaml

# Persist PATH and others for future sessions
echo >> $HOME/.bashrc
echo "# From Cardano Node Script build-node-code.sh" >> $HOME/.bashrc
echo "export PATH=\"$HOME/.local/bin:$HOME/.ghcup/bin:\$PATH\"" >> $HOME/.bashrc
echo "export LD_LIBRARY_PATH=\"/usr/local/lib:\$LD_LIBRARY_PATH\"" >> $HOME/.bashrc
echo "export PKG_CONFIG_PATH=\"/usr/local/lib/pkgconfig:\$PKG_CONFIG_PATH\"" >> $HOME/.bashrc

export PATH="$HOME/.local/bin:$HOME/.ghcup/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# Install Cabal
echo "- Installing Cabal $CABAL_VERSION_TO_INSTALL..."
ghcup install cabal $CABAL_VERSION_TO_INSTALL
ghcup set cabal $CABAL_VERSION_TO_INSTALL

cabal update
CABAL_VERSION=$(cabal --version | head -n 1)
echo "- Installed Cabal version $CABAL_VERSION"

# Install GHC
echo "- Installing GHC $GHC_VERSION_TO_INSTALL..."
ghcup install ghc $GHC_VERSION_TO_INSTALL
ghcup set ghc $GHC_VERSION_TO_INSTALL

GHC_VERSION=$(ghc --version)
echo "- Installed GHC version $GHC_VERSION"

# Install liblmdb
echo - Installing liblmdb
sudo apt-get install liblmdb-dev -y

# Install LibSodium from Git and build it
echo - Installing LibSodium
mkdir -p $HOME/src
cd $HOME/src
git clone https://github.com/intersectmbo/libsodium
cd $HOME/src/libsodium
git checkout dbb48cce5429cb6585c9034f002568964f1ce567
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
git clone --depth 1 --branch ${SECP256K1_VERSION_TAG} https://github.com/bitcoin-core/secp256k1
cd $HOME/src/secp256k1
$HOME/src/secp256k1/autogen.sh
$HOME/src/secp256k1/configure --enable-module-schnorrsig --enable-experimental
make
make check
sudo make install
sudo ldconfig
cd $HOME
rm -rf $HOME/src
echo - Installed libsecp256k1

# Install libblst
echo - Installing libblst version $BLST_VERSION_TAG
mkdir -p $HOME/src
cd $HOME/src
git clone --depth 1 --branch ${BLST_VERSION_TAG} https://github.com/supranational/blst
cd blst
./build.sh
cat > libblst.pc << EOF
prefix=/usr/local
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libblst
Description: Multilingual BLS12-381 signature library
URL: https://github.com/supranational/blst
Version: ${BLST_VERSION_TAG#v}
Cflags: -I\${includedir}
Libs: -L\${libdir} -lblst
EOF
sudo cp libblst.pc /usr/local/lib/pkgconfig/
sudo cp bindings/blst_aux.h bindings/blst.h bindings/blst.hpp /usr/local/include/
sudo cp libblst.a /usr/local/lib
sudo chmod u=rw,go=r /usr/local/{lib/{libblst.a,pkgconfig/libblst.pc},include/{blst.{h,hpp},blst_aux.h}}
cd $HOME
rm -rf $HOME/src/blst
echo - Installed libblst

# Install cardano-node from Git and build it
echo - Installing cardano node version $CARDANO_NODE_VERSION_TO_INSTALL
mkdir -p $HOME/src
cd $HOME/src
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node/
git fetch --all --recurse-submodules --tags
git checkout tags/$CARDANO_NODE_VERSION_TO_INSTALL
cabal configure -O0 --with-compiler=ghc-$GHC_VERSION_TO_INSTALL
echo "package cardano-crypto-praos" >>  cabal.project.local
echo "  flags: -external-libsodium-vrf" >>  cabal.project.local

cabal clean
cabal update
cabal build cardano-node cardano-cli cardano-tracer

mkdir -p $HOME/.local/bin

cp -p $(find dist-newstyle/ -name "cardano-node" -type f | head -n 1) $HOME/.local/bin/
cp -p $(./scripts/bin-path.sh cardano-cli) $HOME/.local/bin/
cp -p $(./scripts/bin-path.sh cardano-tracer) $HOME/.local/bin/
cd $HOME

CARDANO_NODE_VERSION_INSTALLED=$(cardano-node --version)
CARDANO_CLI_VERSION_INSTALLED=$(cardano-cli --version)
CARDANO_TRACER_VERSION_INSTALLED=$(cardano-tracer --version)

echo - Successfully installed cardano-node $CARDANO_NODE_VERSION_INSTALLED, cardano-cli $CARDANO_CLI_VERSION_INSTALLED, and cardano-tracer $CARDANO_TRACER_VERSION_INSTALLED
