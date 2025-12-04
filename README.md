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
Run
```
./make-cardano-sudo-user.sh
```
Now log in as Cardano User

## Basic Harden Steps
./harden-node.sh

## Step 1: Harden your core server
[See also: Harden Ubuntu](https://web.archive.org/web/20220407101050/https://www.lifewire.com/harden-ubuntu-server-security-4178243)
[See also: Secure Ubuntu](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3)
- SSH only via keys, not password
- Change SSH default port from 22
- Allow SSH only from your relay node(s)
- Close all unneeded ports except SSH and the core node port 3001
- Ensure chrony/NTPdate is active

## Step 2: Harden your relay server
[See also: Harden Ubuntu](https://web.archive.org/web/20220407101050/https://www.lifewire.com/harden-ubuntu-server-security-4178243)
[See also: Secure Ubuntu](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3)
- SSH only via keys, not password
- Change SSH default port from 22
- Allow SSH only from where absolutely needed
- Close all unneeded ports except SSH and the relay node port 3000
- Ensure chrony/NTPdate is active

## Step 3: Build the cardano-cli and cardano
`./build-node-code.sh CABAL_VERSION GHC_VERSION CARDANO_NODE_VERSION`

Latest current versions are 3.12.1.0 for CABAL_VERSION, 9.6.7 for GHC_VERSION and 10.5.1 for CARDANO_NODE_VERSION

## Step 4 
`./set-net.sh mainnet|preview|preprod`

Set the net you want to run on (testnet or mainnet)
Will also automatically download the respective configuration files, i.e. it will automatically run `./get-config.sh mainnet|preview|preprod`

## Step 4.5
`./create-node-runner-binary.sh full|relay|core NETWORK_INTERFACE_NODE_IP NETWORK_INTERFACE_NODE_PORT`

Create the executable that will run your cardano node. Determine which node type (you will start with a full node first, so you can get the blockchain and perform the transactions required to register your stakepool, before you can create a relay or core node)
Make sure to use the IP and port that your network interface has, which could be different (for example in AWS) from your public IP4 address.

## Step 4.6
`./create-node-runner-service.sh full|relay|core`

Create a systemd script for your node and install it. This will ensure your node will auto-restart if it crashes or if the server restarts. You can now run your node with

## Step 4.7

Adjust the `mithril-bootstrap.sh` file with the current mithril settings for your network type as needed

Run `mithril-bootstrap.sh`

Once the latest mithril snapshot is downloaded into the `db` directory of the current directory, move it to its final location via 

`mv db /home/cardano/node`

## Step 4.8

Set up Cardano tracer which is built as part of the previous build steps, by running

`./create-tracer-service.sh`

This will create and start the service and copy the configuration file into its place. Edit the configuration file if need be under `/home/cardano/cardano-node-conf/cardano-tracer.json`
Adjust the Network magic and other settings if need be. After making changes, be sure to restart via

`sudo systemctl restart cardano-tracer`

## Step 4.9

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

# Monitoring

`cardano-tracer` is built as part of the build scripts and needs to be installed. However, the metrics are only collected locally and still need to be pushed out. We are using Grafana Alloy to do so.

Follow the steps here to install alloy as a service:

https://grafana.com/docs/alloy/latest/set-up/install/linux/

Then ensure the service is enabled and started

```
sudo systemctl enable alloy
sudo systemctl start alloy
```

After that, adjust your `config.alloy` file based on the template in this directory. Add the right labels you want to add and replace the variables that contain the Grafana Prometheus URL, user and password to push to.

Adjust the prometheus subpath `relay-fi` according to the `TraceOptionNodeName` parameter in your node's `config.json`. If `TraceOptionNodeName` is not present in your config, the URL will be something dynamically generated and can be discovered by running `curl -v "http://localhost:12798"` to get the list of metrics links.

Restart all services
```
sudo systemctl restart cardano-tracer
sudo systemctl restart cardano-node
sudo systemctl restart alloy
```


---------------------------------------------------------------

# Register pledge wallet to vote in Catalyst

Ensure `bech32`, `catalyst-toolbox` and `cardano-signer` are in a subfolder called `catalyst` and executable on both your relay and offline machine (see also: https://forum.cardano.org/t/registering-several-wallets-accounts-to-the-same-catalyst-voting-key/120829)

From the main scripts folder on your offline machine, run this and replace the pin with your desired voting pin, stake address name and stake payment address name

`catalyst-offline-register-pledge-for-vote.sh PIN STAKEADDRESS STAKEPAYMENTADDRESS`

After running this, retrieve the png file from the catalyst subfolder and store it in a safe place (this QR code image combined with your PIN lets you vote in Catalyst).
Copy the catalyst/*.cbor file to your relay (also into the catalyst subfolder). Now run

`query.sh STAKEPAYMENTADDRESS`

Find a usable UTXO and index, then run the below and replace UTXO_IN with the UTXO from above in the format txHash#txIndex

`catalyst-build-register-transaction.sh STAKEPAYMENTADDRESS UTXO_IN`

Now you have a raw transaction to witness and sign on your offline machine. Copy `txtmp/tx.raw` to your offline machine and run to sign the transaction with the key that pays for the fees

`catalyst-offline-sign-register-transaction STAKEPAYMENTADDRESS`

Copy the resulting `txtmp/tx.signed` to your relay and run

`submit-transaction.sh`

---------------------------------------------------------------

# Vote on a governance action

Copy the `governance/sample-vote-body-cip100.json` file to the `hazelpool-web` repository into the `vote/unsigned` folder and give a name matching the governance action. In our example we will save it as `test-vote-unsigned.json`

Update the rationale in the file.

Copy the file onto the cold node where `cardano-signer` is available (https://github.com/gitmachtl/scripts/tree/master/cardano)

Run `cardano-signer sign --cip100 --secret-key cold.skey --author-name "Nils Codes" --data-file "test-vote-unsigned.json" --out-file "test-vote.json"`

We use short names for the output files to keep the final URL below 64 characters so it fits easily into the metadata of the transaction.

Copy the signed file `test-vote.json` back to a internet connected computer, place it in the `hazelpool-web` repository into the `vote` folder, commit and push to Git and publish to the website according to your current setup.

Find the governance action ID (format is `hash#index`, for example `47a0e7a4f9383b1afc2192b23b41824d65ac978d7741aca61fc1fa16833d1111#0`) on https://gov.tools or https://tempo.vote

Ensure the pool VKey (Verification Key) is present in the scripts directory with the file name `pool.node.vkey`

On an online node with the scripts from above installed, run the following command, adjusting the governance ID and verified working rationale URL with the signed vote.

`./24a_genVote.sh pool.node 47a0e7a4f9383b1afc2192b23b41824d65ac978d7741aca61fc1fa16833d1111#0 "url: https://info.hazelpool.com/vote/test-vote.json"`

You will then be prompted a few things. Agree as appropriate. A file like `pool_250825075234.pool.vote` will be created containing the unsigned vote transaction

Run 

`./01_workOffline.sh new`

to create a new offline workspace

Ensure an appropriate payment address and vkey are available, that you have signing rights for. In our case, an address and vkey file are present in the directory as `pledge.payment.addr` and `pledge.payment.vkey`

Run

`./01_workOffline.sh add pledge.payment`

To add its UTxOs to the offline workspace

Copy both files (the vote and `offlineTransfer.json`) back to the cold node into the ATADA scripts directory with the scripts configured in offline mode and a working cardano-cli and cardano-node binary available.

`./24b_regVote.sh pool.node pledge.payment pool_250825075234.pool.vote "msg: My votings as a DRep, woohoo!"`

The `msg` parameter is optional for the transaction that registers the vote (not for the vote itself). `pool.node` points to the same type of files as above, but now including a signing key file `pool.node.skey`, same for `pledge.payment`.

Copy the `offlineTransfer.json` file to the live node

Run 

`./01_workOffline.sh execute`

This will prompt you to verify and submit the transaction. After submission, the vote will appear on chain.

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

Verify counter # is correct as described here:
https://ecp.gitbook.io/how-to-guides-for-coincashew-method-cardano-spos/maintenance-and-daily-operations/maintenance-and-daily-operations/adjust-node.counter-for-kes

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

`./update-node-binary.sh GHC_VERSION CARDANO_NODE_VERSION`

Start the service again

`sudo systemctl start cardano-node`


## How to create a cardano-db-sync out of nowhere
Install Ubuntu 22.04
Deploy these scripts into a script folder and make them executable
Create a cardano user and make him sudo via

`./make-cardano-sudo-user.sh`

Log in as the cardano user

Install docker-compose

`sudo apt install apt-transport-https ca-certificates curl software-properties-common`

`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

`sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable"`

`sudo apt-get install docker-ce docker-compose`

`sudo systemctl enable docker`

`sudo systemctl start docker`

`sudo usermod -aG docker cardano`

`sudo reboot`

Log in as the cardano user again
Execute

`git clone https://github.com/IntersectMBO/cardano-db-sync.git`

`cd cardano-db-sync`

`git checkout tags/13.6.0.5`

Edit the docker-compose.yml file and comment out the db-sync and postgres services and corresponding volumes and run `docker compose up -d`
Run `docker compose stop` after 30 seconds
Copy the backed up db directory of a fully synched node into the cardano-node-db volume location and set file permissions to match the existing file permissions. Make sure to delete the existing ledger files.
Run `docker compose start` and wait until the the cardano-node is fully synched
Uncomment the previously commented out services in the docker-compose.yml file

Run this with the correct snapshot from https://update-cardano-mainnet.iohk.io/cardano-db-sync/index.html matching your cardano-db-sync version

`RESTORE_SNAPSHOT=https://update-cardano-mainnet.iohk.io/cardano-db-sync/13/db-sync-snapshot-schema-13-block-7770734-x86_64.tgz NETWORK=mainnet docker compose up -d`

Then to see the progress, run 

`docker compose logs -f`

## Mithril Bootstrap

### Preprod

Add to .bashrc

export MITHRIL_IMAGE_ID_PREPROD=main-25bb9a6
export AGGREGATOR_ENDPOINT_PREPROD=https://aggregator.release-preprod.api.mithril.network/aggregator
export GENESIS_VERIFICATION_KEY_PREPROD=5b3132372c37332c3132342c3136312c362c3133372c3133312c3231332c3230372c3131372c3139382c38352c3137362c3139392c3136322c3234312c36382c3132332c3131392c3134352c31332c3233322c3234332c34392c3232392c322c3234392c3230352c3230352c33392c3233352c34345d

mithril_client_preprod () {
  docker run --rm -e NETWORK=preprod -e GENESIS_VERIFICATION_KEY=$GENESIS_VERIFICATION_KEY_PREPROD -e AGGREGATOR_ENDPOINT=$AGGREGATOR_ENDPOINT_PREPROD --name='mithril-client' -v $(pwd):/app/data -u $(id -u) ghcr.io/input-output-hk/mithril-client:$MITHRIL_IMAGE_ID_PREPROD $@
}

Run source .bashrc

Run `mithril_client_preprod snapshot list``
Find latest snapshot
Run `mithril_client_preprod snapshot download $DIGEST_ID`
Copy db folder into docker-compose db mounted folder for node you are planning to run
start node