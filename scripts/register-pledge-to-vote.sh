#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: register-pledge-to-vote.sh TTL TARGETADDRESS"
    exit 2
fi

mkdir -p txtmp

PIN=$1
PAY_TO_ADDRESS=$2
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)

./catalyst/cardano-signer keygen --cip36 --json-extended --out-skey catalyst/catalyst_reg_pledge_acc_0.skey --out-vkey catalyst/catalyst_reg_pledge_acc_0.vkey --out-file catalyst/catalyst_reg_pledge_acc_0.json
./catalyst/catalyst-toolbox qr-code encode --pin $PIN --input <(cat catalyst/catalyst_reg_pledge_acc_0.skey | jq -r .cborHex | cut -c 5-132 | ./catalyst/bech32 "ed25519e_sk") --output catalyst/catalyst_reg_pledge_acc_0.png img

