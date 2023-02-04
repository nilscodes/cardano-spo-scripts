#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Usage: create-pool-metadata-file.sh POOLNAME POOLDESCRIPTION POOLTICKER POOLHOMEPAGE EXTENDED_METADATA_URL"
    exit 2
fi

mkdir -p metadata

STAKE_POOL_NAME=$1
STAKE_POOL_DESCRIPTION=$2
STAKE_POOL_TICKER=$3
STAKE_POOL_HOMEPAGE=$4
STAKE_POOL_EXTENDED_METADATA_URL=$5

# Create metadata file
echo "{\"name\":\"$STAKE_POOL_NAME\",\"description\":\"$STAKE_POOL_DESCRIPTION\",\"ticker\":\"$STAKE_POOL_TICKER\",\"homepage\":\"$STAKE_POOL_HOMEPAGE\",\"extended\":\"$STAKE_POOL_EXTENDED_METADATA_URL\"}" | jq '.' > metadata/stake-pool-metadata.json
cat metadata/stake-pool-metadata.json

# Hash Metadata file
cardano-cli stake-pool metadata-hash \
  --pool-metadata-file metadata/stake-pool-metadata.json > metadata/stake-pool-metadata.hash

echo "Metadata file is now located in metadata/stake-pool-metadata.json. Please upload to a < 65 character URL and note the URL for later in the registration process"