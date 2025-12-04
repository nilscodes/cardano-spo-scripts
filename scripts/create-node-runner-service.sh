#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: create-node-runner-service.sh full|relay|core"
    exit 2
fi

NODE_TYPE=$1

echo Adding systemd service cardano-node.service

cp ./cardano-node-template.service ./cardano-node.service

sed -i 's,$HOME,'"$HOME"',g' cardano-node.service
sed -i 's,$NODE_TYPE,'"$NODE_TYPE"',g' cardano-node.service
sudo mv ./cardano-node.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/cardano-node.service
sudo systemctl daemon-reload
sudo systemctl enable cardano-node