// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/L2RegistryFactory.sol";

contract FactoryDeployer is Script {
    function setUp() public {}

    function run() public {
        // Get private key and add 0x prefix if missing
        string memory rawKey = vm.envString("PRIVATE_KEY");
        bytes memory privateKeyBytes = vm.parseBytes(rawKey);
        uint256 deployerPrivateKey = uint256(bytes32(privateKeyBytes));

        vm.startBroadcast(deployerPrivateKey);

        // Use a fixed salt for consistent addresses across chains
        string memory saltString = vm.envString("SALT");
        bytes32 salt = keccak256(abi.encodePacked(saltString));

        console.log("Using salt string:", saltString);
        console.log("Computed salt:", vm.toString(salt));

        // Get the CREATE2 deployer address used by Foundry
        address create2Deployer = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

        // Get the bytecode of the factory (including constructor args)
        bytes memory bytecode = abi.encodePacked(
            type(L2RegistryFactory).creationCode,
            abi.encode(salt) // Include constructor parameter
        );

        // Calculate the expected factory address
        address expectedFactoryAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            create2Deployer,
                            salt,
                            keccak256(bytecode)
                        )
                    )
                )
            )
        );

        console.log("Expected Factory address:", expectedFactoryAddress);

        // Calculate expected implementation address
        bytes memory implBytecode = type(L2Registry).creationCode;
        address expectedImplAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            expectedFactoryAddress,
                            salt,
                            keccak256(implBytecode)
                        )
                    )
                )
            )
        );

        console.log("Expected Implementation address:", expectedImplAddress);

        // Deploy the factory using CREATE2
        address factoryAddress;
        assembly {
            factoryAddress := create2(
                0,
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )
        }

        require(factoryAddress != address(0), "Create2: Failed on deploy");
        console.log("Actual Factory address:", factoryAddress);
        require(
            factoryAddress == expectedFactoryAddress,
            "Factory address mismatch"
        );

        // Verify the implementation address
        L2RegistryFactory factory = L2RegistryFactory(factoryAddress);
        address actualImplAddress = factory.getImplementationAddress();
        console.log("Actual Implementation address:", actualImplAddress);
        require(
            actualImplAddress == expectedImplAddress,
            "Implementation address mismatch"
        );

        vm.stopBroadcast();
    }
}
