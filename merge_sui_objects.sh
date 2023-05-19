#!/usr/bin/env bash
set -euo pipefail

sui_objects=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "method": "suix_getOwnedObjects",
    "jsonrpc": "2.0",
    "id": "1",
    "params": [
        "'${VALIDATOR_ADDRESS}'",
        {
            "filter": {
                "StructType": "0x2::coin::Coin<0x2::sui::SUI>"
            }
        }
    ]
}' https://rpc.mainnet.sui.io/ | jq -r '.result.data')

first_sui_object=$(echo "${sui_objects}" | jq -r '.[0] | .data.objectId')
echo "Merging SUI objects to: ${first_sui_object}"

# Merge all SUI coin objects into the first one.
# TODO: this can actually be executed with a single transaction block.
echo "${sui_objects}" | jq -r '.[1:] | .[] | .data.objectId' | while read sui_object_id; do
    echo "Merging staked SUI object: ${sui_object_id}"
    sui client merge-coin --primary-coin "${first_sui_object}" --coin-to-merge "${sui_object_id}" --gas-budget "${DEFAULT_GAS_BUDGET}"
done
