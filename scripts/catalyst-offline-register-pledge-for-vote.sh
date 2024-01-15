#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: catalyst-register-pledge-for-vote.sh PIN STAKEADDRESS STAKEPAYMENTADDRESS"
    exit 2
fi

PIN=$1
STAKE=$2
STAKE_PAYMENT=$3
NETIDENTIFIER=$(cat $HOME/cardano-node-conf/cardano-cli-net-param)
CATALYST_ACC_NAME=catalyst_reg_pledge_acc_0

# Generate voting keys and QR code with PIN
./catalyst/cardano-signer keygen --cip36 --json-extended --out-skey catalyst/$CATALYST_ACC_NAME.skey --out-vkey catalyst/$CATALYST_ACC_NAME.vkey --out-file catalyst/$CATALYST_ACC_NAME.json
./catalyst/catalyst-toolbox qr-code encode --pin $PIN --input <(cat catalyst/$CATALYST_ACC_NAME.skey | jq -r .cborHex | cut -c 5-132 | ./catalyst/bech32 "ed25519e_sk") --output catalyst/$CATALYST_ACC_NAME.png img

# Sign the vote certificate with the voting key, the payment address for Catalyst rewards and the stake key to register
./catalyst/cardano-signer sign --cip36 --payment-address $(cat addr/$STAKE_PAYMENT.addr) --vote-public-key catalyst/$CATALYST_ACC_NAME.vkey --secret-key keys/$STAKE.skey --out-cbor catalyst/$CATALYST_ACC_NAME.cbor

echo "Copy the file catalyst/$CATALYST_ACC_NAME.cbor to your relay, save the PNG file of the same name in a safe location (remember the PIN you used!) and  on the relay, run ./catalyst-build-register-transaction.sh"