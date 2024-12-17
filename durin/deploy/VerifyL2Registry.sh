#!/bin/bash

# Load environment variables
source .env

# Get the deployed contract address (you should save this after deployment)
REGISTRY_ADDRESSS="${REGISTRY_ADDRESS}"

# Get your chain's Etherscan API key from env
ETHERSCAN_API_KEY="${ETHERSCAN_API_KEY}"

# Verify on desired network (update network name as needed)
# Examples: arbitrum, optimism, base, etc.
NETWORK="${NETWORK}"


# Run verification
echo "Verifying contract..."
forge verify-contract \
    --chain "${NETWORK}" \
    --etherscan-api-key "${ETHERSCAN_API_KEY}" \
    --watch \
    --constructor-args $(cast abi-encode "constructor()") \
    "${REGISTRY_ADDRESS}" \
    src/L2Registry.sol:L2Registry


# Check verification status
echo "Verification submitted. Check status on the block explorer."