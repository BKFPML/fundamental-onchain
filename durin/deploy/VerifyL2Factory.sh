#!/bin/bash

# Load environment variables
source .env

# Get deployment addresses and API keys
FACTORY_ADDRESS="${FACTORY_ADDRESS}"
ETHERSCAN_API_KEY="${ETHERSCAN_API_KEY}"
NETWORK="${NETWORK}"

# Get the salt value that was used during deployment
SALT_STRING="${SALT}"
# Calculate the salt bytes32 value the same way as in your deploy script
SALT_BYTES32=$(cast keccak "$(cast --from-utf8 ${SALT_STRING})")

# Encode constructor arguments (bytes32 salt)
CONSTRUCTOR_ARGS=$(cast abi-encode "constructor(bytes32)" "${SALT_BYTES32}")

echo "Using salt string: ${SALT_STRING}"
echo "Computed salt bytes32: ${SALT_BYTES32}"
echo "Constructor args: ${CONSTRUCTOR_ARGS}"
echo "Verifying contract..."

forge verify-contract \
    --chain "${NETWORK}" \
    --etherscan-api-key "${ETHERSCAN_API_KEY}" \
    --watch \
    --constructor-args ${CONSTRUCTOR_ARGS} \
    "${FACTORY_ADDRESS}" \
    src/L2RegistryFactory.sol:L2RegistryFactory

echo "Verification submitted. Check status on the block explorer."