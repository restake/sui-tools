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

# Withdraw all staked SUI objects, one by one.
echo "${stake_objects}" | jq -r '.[] | .stakedSuiId' | while read stakedSuiId; do
    echo "Withdrawing staked SUI object: ${stakedSuiId}"
    sui client call --package 0x3 --module sui_system --function request_withdraw_stake --args 0x5 "${stakedSuiId}" --gas-budget 20000000
done
