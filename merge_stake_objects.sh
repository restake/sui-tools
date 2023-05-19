#!/usr/bin/env bash
set -euo pipefail

stake_objects=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "method": "suix_getStakes",
    "jsonrpc": "2.0",
    "id": "1",
    "params": {
        "owner": "'${VALIDATOR_ADDRESS}'"
    }
}' https://rpc.mainnet.sui.io/ | jq -r '.result | to_entries[] | select(.value.validatorAddress == "'${VALIDATOR_ADDRESS}'") | .value.stakes')

first_stake_object=$(echo "${stake_objects}" | jq -r '.[0] | .stakedSuiId')
echo "Merging stake objects to: ${first_stake_object}"

# Merge all staked SUI objects into the first one.
echo "${stake_objects}" | jq -r '.[1:] | .[] | .stakedSuiId' | while read staked_sui_id; do
    echo "Merging staked SUI object: ${staked_sui_id}"
    sui client call merge-coin --primary-coin "${first_stake_object}" --coin-to-merge "${staked_sui_id}" --gas-budget 20000000
done
