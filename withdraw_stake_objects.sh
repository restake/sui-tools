#!/usr/bin/env bash
set -euo pipefail

rpc_url="https://rpc.${SUI_NETWORK}.sui.io/"

stake_objects=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "method": "suix_getStakes",
    "jsonrpc": "2.0",
    "id": "1",
    "params": {
        "owner": "'${VALIDATOR_ADDRESS}'"
    }
}' "${rpc_url}"| jq -r '.result | to_entries[] | select(.value.validatorAddress == "'${VALIDATOR_ADDRESS}'") | .value.stakes')

# Withdraw all staked SUI objects, one by one.
echo "${stake_objects}" | jq -r '.[] | .stakedSuiId' | while read staked_sui_id; do
    echo "Withdrawing staked SUI object: ${staked_sui_id}"
    sui client call --package 0x3 --module sui_system --function request_withdraw_stake --args 0x5 "${staked_sui_id}" --gas-budget "${DEFAULT_GAS_BUDGET}"
    sleep 1
done
