#!/bin/bash

NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

currentSlot=$(cardano-cli query tip $NETIDENTIFIER | jq .slot)
echo "Current slot is $currentSlot"