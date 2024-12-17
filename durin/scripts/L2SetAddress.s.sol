// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @author darianb.eth
/// @custom:project Durin
/// @custom:company NameStone

// Sets an address record in the L2Registry contract
// Load environment variables and run the script
// source .env && forge script scripts/L2SetAddress.s.sol:L2SetAddress --rpc-url $RPC_URL --broadcast

import {Script} from "forge-std/Script.sol";
import {L2Registry} from "src/L2Registry.sol";
import {console2} from "forge-std/console2.sol";

contract L2SetAddress is Script {
    function setUp() public {}

    function run() public {
        // Load environment variables
        string memory rawKey = vm.envString("PRIVATE_KEY");
        bytes memory privateKeyBytes = vm.parseBytes(rawKey);
        uint256 deployerPrivateKey = uint256(bytes32(privateKeyBytes));

        address registryAddress = vm.envAddress("REGISTRY_ADDRESS");
        string memory name = vm.envString("NAME_TO_REGISTER");
        address addressToSet = vm.envAddress("OWNER_ADDRESS");

        // Calculate labelhash
        bytes32 labelhash = keccak256(abi.encodePacked(name));

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Get the registry contract instance
        L2Registry registry = L2Registry(registryAddress);

        // Create the address array with ETH address (coin type 60)
        L2Registry.Addr[] memory addrs = new L2Registry.Addr[](1);
        addrs[0] = L2Registry.Addr({
            coinType: 60, // ETH
            value: abi.encodePacked(addressToSet)
        });

        // Empty arrays/values for other parameters we're not setting
        L2Registry.Text[] memory texts = new L2Registry.Text[](0);
        bytes memory contenthash;

        // Set the records
        registry.setRecords(labelhash, texts, addrs, contenthash);

        vm.stopBroadcast();

        // Log the results
        console2.log("Set address record for name:", name);
        console2.log("Labelhash:", vm.toString(labelhash));
        console2.log("Address set to:", addressToSet);
    }
}
