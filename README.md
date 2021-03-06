# Cardano Scripts to Generate Keys, Signatures etc. to create a stake pool

Assuming you have an existing address to pay your desposit cost and pledge fee with
TTL is the time in slots to wait until considering this transaction failed if not processed

In this example we will use

Relay Node IP: 1.1.1.1
Relay Node Port: 3000
Core Node IP: 2.2.2.2
Core Node Port: 3001

Steps:

## User Steps
./make-cardano-sudo-user.sh

## Basic Harden Steps
./harden-node.sh

## Step 1: Harden your core server
[See also: Harden Ubuntu](https://www.lifewire.com/harden-ubuntu-server-security-4178243)
[See also: Secure Ubuntu](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3)
- SSL only via keys, not password
- Change SSL default port from 22
- Allow SSL only from your relay node(s)
- Close all unneeded ports except SSL and the core node port 3001

## Step 2: Harden your relay server
[See also: Harden Ubuntu](https://www.lifewire.com/harden-ubuntu-server-security-4178243)
[See also: Secure Ubuntu](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3)
- SSL only via keys, not password
- Change SSL default port from 22
- Allow SSL only from where absolutely needed
- Close all unneeded ports except SSL and the relay node port 3000

## Step 3: Build the cardano-cli and cardano
`./build-node-code.sh CABAL_VERSION GHC_VERSION CARDANO_NODE_VERSION`

Latest current versions are 3.4.0.0 for CABAL_VERSION, 8.10.4 for GHC_VERSION and 1.29.0 for CARDANO_NODE_VERSION

## Step 4 
`./set-net.sh mainnet|testnet [TESTNET_MAGIC_ID]`

Set the net you want to run on (testnet or mainnet)
Will also automatically download the respective configuration files, i.e. it will automatically run `./get-config.sh conf testnet|mainnet`

## Step 4.5
`./create-node-runner-binary.sh full|relay|core NETWORK_INTERFACE_NODE_IP NETWORK_INTERFACE_NODE_PORT`

Create the executable that will run your cardano node. Determine which node type (you will start with a full node first, so you can get the blockchain and perform the transactions required to register your stakepool, before you can create a relay or core node)
Make sure to use the IP and port that your network interface has, which could be different (for example in AWS) from your public IP4 address.

## Step 4.6
`./create-node-runner-service.sh full|relay|core`

Create a systemd script for your node and install it. This will ensure your node will auto-restart if it crashes or if the server restarts. You can now run your node with

`sudo systemctl start cardano-node`

and get its status with

`sudo systemctl status cardano-node`

current log files with

`journalctl --unit=cardano-node --follow`

## Step 5: Make a stake address and stake payment address (only on Airgapped Offline Machine!)
`./offline-make-stake-and-payment-addresses.sh stake stake-payment`

## Step 5.5: Set up payment address and keys
- Create a payfrom.addr file containing the address you will pay from (WARNING: All funds in that address will be transferred and it can only have one transaction in it!)
`./make-keys-and-address.sh payfrom`

Copy addr/payfrom.addr to your online node

## Step 5.7: Create stake registration certificate (only on Airgapped Offline Machine!)
`./offline-create-stake-registration-cert.sh stake`

## Step 6: Register the stake address with the cardano net (online machine)
`./register-stake-address.sh TTL payfrom stake-payment stake`
Sign the transaction on the offline machine
`./offline-register-stake-address-sign.sh `
Copy the transaction back to your core node and submit it
`./submit-transaction.sh`

## Step 7: Verify stake funding is present
`./query.sh stake-payment`

## Generate Topology files for your nodes
`./create-pool-topology-files.sh`

## Replace topology files on both core and relay nodes

## Restart Relay Node(s)
`sudo systemctl restart cardano-node`

## Restart Core Node
`sudo systemctl restart cardano-node`

## Create Metadata file (online machine)
`./create-pool-metadata-file.sh POOLNAME POOLDESCRIPTION POOLTICKER POOLHOMEPAGE`

## Upload Metadata file to a URL with less than 65 characters

## Copy pool relay info
Copy the topology and metadata folders to your airgapped offline machine

## Create Stake Pool Keys (only on Airgapped Offline Machine!)
`./offline-create-pool-keys.sh`

## Generate Stake Pool Registration Certificate (only on Airgapped Offline Machine!)
`./offline-generate-stake-pool-registration-certificate.sh METADATAURL`

## Generate the stake pool registration transaction (on your online machine)
`./build-stake-pool-registration-transaction.sh TTL`

## Sign the stake pool registration transaction (only on Airgapped Offline Machine!)
`./offline-build-stake-pool-registration-transaction.sh`

## Transfer your Pledge and Deposit
Transfer it using your wallet of choice to the address in addr/payfrom.addr

## Submit Transaction for Stake Pool Registration and Deposit Payment
`./submit-transaction.sh`

---------------------------------------------------------------

## Create rewards transfer transaction by running this command
`./transfer-rewards-create-transaction.sh TTL TARGETADDRESS`

## Copy txtmp/tx.raw to your offline machine

## Sign the rewards transfer transaction by running this command
`./transfer-rewards-sign-transaction.sh TARGETADDRESS`

## Copy txtmp/tx.signed back into the txtmp folder of your online machine

## Submit the transaction
`./submit-transaction.sh`

---------------------------------------------------------------

## Rotate KES keys
First, on the live block producer node run
`./prepare-new-kes-key-files.sh`

Then copy the KES files over to your offline machine and as instructed, run
`./offline-regenerate-nodecert-for-kes-key KES_PERIOD`

Copy the new node-op.cert file from the certs subfolder back onto your core node and run
`sudo systemctl restart cardano-node` or (if security updates are required) `sudo reboot`

Use the opportunity to reboot the relay(s) as well

---------------------------------------------------------------

## Update Pledge or metadata etc for your pool without paying the deposit again
On offline machine, make certs/pool-*.cert writable again
Run
`./offline-generate-stake-pool-registration-certificate METDATAURL`

Copy the two certs/pool-*.cert files to your core node
Run
`./build-update-stake-pool-registration-transaction.sh TTL`

Copy txtmp/tx.raw to your offline machine
Run
`./offline-build-stake-pool-registration-transaction.sh`

Copy txtmp/tx.signed back to your core nore
Run
`./submit-transaction.sh`

---------------------------------------------------------------

## Update node version/binary

Build the cardano-cli and cardano with the new version
`./update-node-code.sh GHC_VERSION CARDANO_NODE_VERSION`

Stop the service
`sudo systemctl stop cardano-node`

Update the binaries and back up the old ones
`./update-node-binaries.sh GHC_VERSION CARDANO_NODE_VERSION`

Start the service again
`sudo systemctl start cardano-node`