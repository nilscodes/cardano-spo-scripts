#!/bin/bash

if [ "$#" -ne 5 ] && [ "$#" -ne 7 ]; then
    echo "Usage: create-pool-topology-files.sh relaydns|relayip RELAYNODE1_IP_OR_DNS RELAYNODE1_PORT CORENODE_IP CORENODE_PORT [RELAYNODE2_IP_OR_DNS RELAYNODE2_PORT]"
    exit 2
fi

RELAY_TYPE=$1
if [ "$RELAY_TYPE" != "relaydns" ] && [ "$RELAY_TYPE" != "relayip" ]; then
    echo "Usage: create-pool-topology-files.sh relaydns|relayip RELAYNODE1_IP_OR_DNS RELAYNODE1_PORT CORENODE_IP CORENODE_PORT [RELAYNODE2_IP_OR_DNS RELAYNODE2_PORT]"
    exit 2
fi

mkdir -p topology
rm -f topology/relay*.txt

RELAYNODE1_IP_OR_DNS=$2
RELAY_NODE1_PORT=$3
CORE_NODE_IP=$4
CORE_NODE_PORT=$5
if [ "$#" -eq 7 ]; then
    RELAYNODE2_IP_OR_DNS=$6
    RELAY_NODE2_PORT=$7
fi

relayNodeFile="relay-topology.json"

if [ "$RELAY_TYPE" = "relaydns" ]; then
    echo $RELAYNODE1_IP_OR_DNS > topology/relay1-dns.txt
else
    echo $RELAYNODE1_IP_OR_DNS > topology/relay1-ip.txt
fi
echo $RELAY_NODE1_PORT > topology/relay1-port.txt

if [ "$#" -eq 7 ]; then
    if [ "$RELAY_TYPE" = "relaydns" ]; then
        echo $RELAYNODE2_IP_OR_DNS > topology/relay2-dns.txt
    else
        echo $RELAYNODE2_IP_OR_DNS > topology/relay2-ip.txt
    fi
    echo $RELAY_NODE2_PORT > topology/relay2-port.txt
    echo "{\"Producers\":[{\"addr\":\"$RELAYNODE1_IP_OR_DNS\",\"port\":$RELAY_NODE1_PORT,\"valency\":1},{\"addr\":\"$RELAYNODE2_IP_OR_DNS\",\"port\":$RELAY_NODE2_PORT,\"valency\":1}]}" | jq '.' > topology/core-node-topology.json
else
    echo "{\"Producers\":[{\"addr\":\"$RELAYNODE1_IP_OR_DNS\",\"port\":$RELAY_NODE1_PORT,\"valency\":1}]}" | jq '.' > topology/core-node-topology.json
fi

echo "[{\"addr\":\"$CORE_NODE_IP\",\"port\":$CORE_NODE_PORT,\"valency\":1}]" | jq '.' > topology/relay-node-data-first.json
jq '.Producers' $relayNodeFile > topology/relay-node-data-rest.json
jq -s '{"Producers":[.[][]]}' topology/relay-node-data-*.json > topology/relay-node-topology.json

rm topology/relay-node-data-first.json
rm topology/relay-node-data-rest.json
cp topology/*-node-topology.json $HOME/cardano-node-conf