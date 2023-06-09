#!/usr/bin/env bash
set -euo pipefail

rpc_url="https://rpc.${SUI_NETWORK}.sui.io/"

# Return all owned SUI coin objects, sorted by balance.
sui_objects=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "method": "suix_getOwnedObjects",
    "jsonrpc": "2.0",
    "id": "1",
    "params": [
        "'${VALIDATOR_ADDRESS}'",
        {
            "filter": {
                "StructType": "0x2::coin::Coin<0x2::sui::SUI>"
            },
            "options": {
                "showContent": true
            }
        }
    ]
}' "${rpc_url}" | jq -r '.result.data | sort_by(.data.content.fields.balance) | reverse')

# Reserve the smallest SUI coin, we'll need to use it later as a gas coin (object) to cover the transaction fees.
gas_object=$(echo "${sui_objects}" | jq -r '.[0] | .data.objectId')
first_sui_object=$(echo "${sui_objects}" | jq -r '.[1] | .data.objectId')

echo "Gas object: ${gas_object}"
echo "Merging SUI objects to: ${first_sui_object}"

# Merge all SUI coin objects into the first one. We'll start iterating the array from the 3rd position.
# TODO: this can actually be executed with a single transaction block.
echo "${sui_objects}" | jq -r '.[2:] | .[] | .data.objectId' | while read sui_object_id; do
    echo "Merging staked SUI object: ${sui_object_id}"
    sui client merge-coin --primary-coin "${first_sui_object}" --coin-to-merge "${sui_object_id}" --gas-budget "${DEFAULT_GAS_BUDGET}"
    sleep 1
done
