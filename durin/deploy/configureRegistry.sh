#!/bin/bash

# Load environment variables
source .env

# Check if required variables are set
if [ -z "$RPC_URL" ] || [ -z "$PRIVATE_KEY" ] || [ -z "$REGISTRY_ADDRESS" ] || \
   [ -z "$REGISTRAR_ADDRESS" ]; then
    echo "Error: Missing required environment variables. Please check your .env file."
    exit 1
fi

# Set Registrar Role on Registry 
echo "Granting REGISTRAR_ROLE to the Registrar..."
cast send $REGISTRY_ADDRESS \
    "addRegistrar(address)" \
    "$REGISTRAR_ADDRESS" \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY

echo "All parameters set successfully!"