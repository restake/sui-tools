#!/usr/bin/env bash
set -euo pipefail

# This script is quite simple. It just sends the provided SUI coin object to the address defined in the .envrc file.
input_coins="${1?'Input coin object IDs are required'}"

echo "SUI object IDs: ${input_coin}"
echo "Recipient address: ${WITHDRAWAL_ADDRESS}"
echo "Proceed? (y/n)"

read prompt

if [[ ! $prompt =~ ^[Yy]$ ]]; then
    echo "Cancelling..."
    exit 1
fi

sui client pay-all-sui --gas-budget "${DEFAULT_GAS_BUDGET}" --recipient "${WITHDRAWAL_ADDRESS}" --input-coins "${input_coins}"
