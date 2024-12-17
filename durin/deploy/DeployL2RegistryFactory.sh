#!/bin/bash
source .env

# Check required env vars
if [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "Error: ETHERSCAN_API_KEY is not set"
    exit 1
fi
if [ -z "$RPC_URL" ]; then
    echo "Error: RPC_URL is not set"
    exit 1
fi
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY is not set"
    exit 1
fi

echo "Deployment Configuration:"
echo "- Ethereum RPC URL is set: ✓"
echo "- Private Key is set: ✓"
echo "- Etherscan API Key is set: ✓"

echo "Building the project..."
forge build --force

echo "Deploying contracts..."

if [ "$NETWORK" = "linea" ] || [ "$NETWORK" = "linea-sepolia" ] || [ "$NETWORK" = "scroll-sepolia" ]; then
    forge script deploy/L2FactoryDeployer.sol:FactoryDeployer \
        --rpc-url $RPC_URL \
        --broadcast \
        --gas-limit 30000000 \
        --priority-gas-price 100000000 \
        --legacy \
        --with-gas-price 500000000 \
        --skip-simulation \
        -vvvv
else
    forge script deploy/L2FactoryDeployer.sol:FactoryDeployer \
        --rpc-url $RPC_URL \
        --broadcast \
        -vvvv
fi