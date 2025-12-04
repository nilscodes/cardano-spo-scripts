#!/usr/bin/env bash
set -euo pipefail

usage() { echo "Usage: $(basename "$0") [next|current]"; }

if [ "$#" -gt 1 ]; then
  usage
  exit 2
fi

choice="${1:-next}"

case "$choice" in
  next|current)
    epoch_arg=(--"$choice")
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    echo "Error: invalid argument '$choice'. Allowed: next | current"
    usage
    exit 2
    ;;
esac

cardano-cli query leadership-schedule \
  --vrf-signing-key-file pool-keys/vrf.skey \
  "${epoch_arg[@]}" \
  --out-file ./slots.json \
  --genesis ../cardano-node-conf/shelley-genesis.json \
  --mainnet \
  --stake-pool-id "$(cat metadata/stakepoolid.txt)"

jq '.[].slotTime
    | strptime("%Y-%m-%dT%H:%M:%SZ")
    | mktime - 7 * 3600
    | strftime("%Y-%m-%d %H:%M:%S")' ./slots.json
