#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: create-node-runner.sh full|relay|core NETWORK_INTERFACE_NODE_IP NETWORK_INTERFACE_NODE_PORT"
    exit 2
fi

NODE_TYPE=$1
NODE_IP=$2
NODE_PORT=$3

mkdir -p $HOME/node

NODE_SHELL_FILE=$HOME/node/run-$NODE_TYPE-node.sh

echo \#!/bin/bash > $NODE_SHELL_FILE

if [ "$NODE_TYPE" = "core" ]; then
    echo $HOME/.local/bin/cardano-node run \\ >> $NODE_SHELL_FILE
    echo  --topology $HOME/cardano-node-conf/core-node-topology.json \\ >> $NODE_SHELL_FILE
    echo  --database-path $HOME/node/db \\ >> $NODE_SHELL_FILE
    echo  --socket-path $HOME/node/db/node.socket \\ >> $NODE_SHELL_FILE
    echo  --host-addr $NODE_IP \\ >> $NODE_SHELL_FILE
    echo  --port $NODE_PORT \\ >> $NODE_SHELL_FILE
    echo  --config $HOME/cardano-node-conf/config.json \\ >> $NODE_SHELL_FILE
    echo  --tracer-socket-path-connect /tmp/forwarder.sock \\ >> $NODE_SHELL_FILE
    echo  --shelley-kes-key $HOME/scripts/pool-keys/kes.skey \\ >> $NODE_SHELL_FILE
    echo  --shelley-vrf-key $HOME/scripts/pool-keys/vrf.skey \\ >> $NODE_SHELL_FILE
    echo  --shelley-operational-certificate $HOME/scripts/certs/node-op.cert >> $NODE_SHELL_FILE
elif [ "$NODE_TYPE" = "relay" ]; then
    echo $HOME/.local/bin/cardano-node run \\ >> $NODE_SHELL_FILE
    echo  --topology $HOME/cardano-node-conf/relay-node-topology.json \\ >> $NODE_SHELL_FILE
    echo  --database-path $HOME/node/db \\ >> $NODE_SHELL_FILE
    echo  --socket-path $HOME/node/db/node.socket \\ >> $NODE_SHELL_FILE
    echo  --host-addr $NODE_IP \\ >> $NODE_SHELL_FILE
    echo  --port $NODE_PORT \\ >> $NODE_SHELL_FILE
    echo  --config $HOME/cardano-node-conf/config.json \\ >> $NODE_SHELL_FILE
    echo  --tracer-socket-path-connect /tmp/forwarder.sock >> $NODE_SHELL_FILE
else
    echo $HOME/.local/bin/cardano-node run \\ >> $NODE_SHELL_FILE
    echo  --topology $HOME/cardano-node-conf/topology.json \\ >> $NODE_SHELL_FILE
    echo  --database-path $HOME/node/db \\ >> $NODE_SHELL_FILE
    echo  --socket-path $HOME/node/db/node.socket \\ >> $NODE_SHELL_FILE
    echo  --host-addr $NODE_IP \\ >> $NODE_SHELL_FILE
    echo  --port $NODE_PORT \\ >> $NODE_SHELL_FILE
    echo  --config $HOME/cardano-node-conf/config.json \\ >> $NODE_SHELL_FILE
    echo  --tracer-socket-path-connect /tmp/forwarder.sock >> $NODE_SHELL_FILE
fi

chmod +x $NODE_SHELL_FILE

echo export CARDANO_NODE_SOCKET_PATH="$HOME/node/db/node.socket" >> $HOME/.bashrc
