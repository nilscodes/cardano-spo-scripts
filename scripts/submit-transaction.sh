#!/bin/bash

NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

# Submit Transaction
cardano-cli transaction submit \
  --tx-file txtmp/tx.signed \
  $NETIDENTIFIER
