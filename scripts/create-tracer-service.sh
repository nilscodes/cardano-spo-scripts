#!/bin/bash

echo Adding systemd service cardano-tracer.service

cp ./cardano-tracer.json $HOME/cardano-node-conf

cp ./cardano-tracer-template.service ./cardano-tracer.service

sed -i 's,$HOME,'"$HOME"',g' cardano-tracer.service
sudo mv ./cardano-tracer.service /etc/systemd/system
sudo chmod 644 /etc/systemd/system/cardano-tracer.service
sudo systemctl daemon-reload
sudo systemctl enable cardano-tracer