#!/bin/bash
/usr/local/bin/cncli sync --host 138.201.29.59 --port 33000 --no-service

MYPOOLID=$(cat metdata/stakepoolid.txt)
echo "LeaderLog - POOLID $MYPOOLID"

SNAPSHOT=$(/home/cardano/.local/bin/cardano-cli query stake-snapshot --stake-pool-id $MYPOOLID --mainnet)

# Next Epoch
# POOL_STAKE=$(jq .poolStakeMark <<< $SNAPSHOT)
# ACTIVE_STAKE=$(jq .activeStakeMark <<< $SNAPSHOT)
# EPOCHTYPE=next

# Current Epoch
# POOL_STAKE=$(jq .poolStakeSet <<< $SNAPSHOT)
# ACTIVE_STAKE=$(jq .activeStakeSet <<< $SNAPSHOT)
# EPOCHTYPE=current

# Last Epoch
POOL_STAKE=$(jq .poolStakeGo <<< $SNAPSHOT)
ACTIVE_STAKE=$(jq .activeStakeGo <<< $SNAPSHOT)
EPOCHTYPE=prev

echo "/usr/local/bin/cncli leaderlog --pool-id $MYPOOLID --pool-vrf-skey pool-keys/vrf.skey --byron-genesis /home/cardano/cardano-node-conf/mainnet-byron-genesis.json --shelley-genesis /home/cardano/cardano-node-conf/mainnet-shelley-genesis.json --pool-stake $POOL_STAKE --active-stake $ACTIVE_STAKE --ledger-set $EPOCHTYPE"
MYPOOL=`/usr/local/bin/cncli leaderlog --pool-id $MYPOOLID --pool-vrf-skey pool-keys/vrf.skey --byron-genesis /home/cardano/cardano-node-conf/mainnet-byron-genesis.json --shelley-genesis /home/cardano/cardano-node-conf/mainnet-shelley-genesis.json --pool-stake $POOL_STAKE --active-stake $ACTIVE_STAKE --ledger-set $EPOCHTYPE`

EPOCH=`jq .epoch <<< $MYPOOL`
echo "\`Epoch $EPOCH\` 🧙🔮:"

SLOTS=`jq .epochSlots <<< $MYPOOL`
IDEAL=`jq .epochSlotsIdeal <<< $MYPOOL`
PERFORMANCE=`jq .maxPerformance <<< $MYPOOL`
echo "\`MYPOOL - $SLOTS \`🎰\`,  $PERFORMANCE% \`🍀max, \`$IDEAL\` 🧱ideal"