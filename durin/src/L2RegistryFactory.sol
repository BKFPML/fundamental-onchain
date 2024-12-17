// ***********************************************
// ▗▖  ▗▖ ▗▄▖ ▗▖  ▗▖▗▄▄▄▖ ▗▄▄▖▗▄▄▄▖▗▄▖ ▗▖  ▗▖▗▄▄▄▖
// ▐▛▚▖▐▌▐▌ ▐▌▐▛▚▞▜▌▐▌   ▐▌     █ ▐▌ ▐▌▐▛▚▖▐▌▐▌
// ▐▌ ▝▜▌▐▛▀▜▌▐▌  ▐▌▐▛▀▀▘ ▝▀▚▖  █ ▐▌ ▐▌▐▌ ▝▜▌▐▛▀▀▘
// ▐▌  ▐▌▐▌ ▐▌▐▌  ▐▌▐▙▄▄▖▗▄▄▞▘  █ ▝▚▄▞▘▐▌  ▐▌▐▙▄▄▖
// ***********************************************
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @author darianb.eth
/// @custom:project Durin
/// @custom:company NameStone
/// @notice Factory contract for deploying new L2Registry instances
/// @dev Uses OpenZeppelin Clones for gas-efficient deployment of registry contracts

import "./L2Registry.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

/// @title L2Registry Factory
/// @notice Facilitates the deployment of new L2Registry instances with proper role configuration
/// @dev Uses minimal proxy pattern through OpenZeppelin's Clones library
contract L2RegistryFactory {
    /// @notice The implementation contract to clone
    address public immutable implementationContract;

    /// @notice The salt used for implementation deployment
    bytes32 public immutable IMPLEMENTATION_SALT;

    /// @notice Emitted when a new registry is deployed
    /// @param registryAddress The address of the newly deployed registry
    /// @param name The name of the registry's ERC721 token
    /// @param symbol The symbol of the registry's ERC721 token
    /// @param baseUri The base URI for the registry's token metadata
    /// @param admin The address granted admin roles for the new registry
    event RegistryDeployed(
        address registryAddress,
        string name,
        string symbol,
        string baseUri,
        address admin
    );

    /// @notice Constructor that deploys the implementation contract deterministically
    /// @param salt The salt used for implementation deployment
    constructor(bytes32 salt) {
        IMPLEMENTATION_SALT = salt;

        // Deploy implementation using CREATE2
        bytes memory bytecode = type(L2Registry).creationCode;
        implementationContract = Create2.deploy(
            0,
            IMPLEMENTATION_SALT,
            bytecode
        );
    }

    /// @notice Gets the deterministic address for the implementation contract
    /// @return The address where the implementation contract will be deployed
    function getImplementationAddress() public view returns (address) {
        bytes memory bytecode = type(L2Registry).creationCode;
        return
            Create2.computeAddress(
                IMPLEMENTATION_SALT,
                keccak256(bytecode),
                address(this)
            );
    }

    /// @notice Deploys a new L2Registry contract with specified parameters using clones
    /// @param name The name for the registry's ERC721 token
    /// @param symbol The symbol for the registry's ERC721 token
    /// @param baseUri The base URI for the registry's token metadata
    /// @return address The address of the newly deployed registry clone
    /// @dev Uses minimal proxy pattern to create cheap clones of the implementation
    function deployRegistry(
        string memory name,
        string memory symbol,
        string memory baseUri
    ) public returns (address) {
        // Clone the implementation contract
        address clone = Clones.clone(implementationContract);
        L2Registry registry = L2Registry(clone);

        // Initialize the clone
        registry.initialize(name, symbol, baseUri);

        // Grant admin roles to the caller
        registry.grantRole(registry.DEFAULT_ADMIN_ROLE(), msg.sender);
        registry.grantRole(registry.ADMIN_ROLE(), msg.sender);

        // Renounce factory's admin roles
        registry.renounceRole(registry.DEFAULT_ADMIN_ROLE(), address(this));
        registry.renounceRole(registry.ADMIN_ROLE(), address(this));

        // Emit event for indexing and tracking purposes
        emit RegistryDeployed(
            address(registry),
            name,
            symbol,
            baseUri,
            msg.sender
        );

        return address(registry);
    }
}
