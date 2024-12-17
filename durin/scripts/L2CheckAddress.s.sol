// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @author darianb.eth
/// @custom:project Durin
/// @custom:company NameStone

// source .env && forge script scripts/L2CheckAddress.s.sol:L2CheckAddress --rpc-url $RPC_URL

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {L2Registry} from "src/L2Registry.sol";
import {console2} from "forge-std/console2.sol";

contract L2CheckAddress is Script {
    function setUp() public {}

    function run() public view {
        // Load environment variables
        address registryAddress = vm.envAddress("REGISTRY_ADDRESS");
        string memory name = vm.envString("NAME_TO_REGISTER");

        // Calculate labelhash
        bytes32 labelhash = keccak256(abi.encodePacked(name));

        // Get the registry contract instance
        L2Registry registry = L2Registry(registryAddress);

        // Get the address for the name
        address resolvedAddress = registry.addr(labelhash);

        // Log the results
        console2.log("Name:", name);
        console2.log("Labelhash:", vm.toString(labelhash));
        if (resolvedAddress == address(0)) {
            console2.log("No address set for this name");
        } else {
            console2.log("Resolved address:", resolvedAddress);
        }

        // Optionally check the owner of the name
        try registry.ownerOf(uint256(labelhash)) returns (address owner) {
            console2.log("Name owner:", owner);
        } catch {
            console2.log("Name is not registered");
        }
    }
}
