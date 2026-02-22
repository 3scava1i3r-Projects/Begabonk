// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./interfaces/IMIDLResolver.sol";
import "./interfaces/IMIDLRegistry.sol";

/**
 * @title MIDLResolver
 * @dev A resolver contract for MIDL names that supports multiple record types.
 */
contract MIDLResolver is IMIDLResolver, ERC165 {
    // The registry this resolver uses
    IMIDLRegistry public registry;

    // Mapping from node to ETH address
    mapping(bytes32 => address) private addresses;

    // Mapping from node to multi-chain addresses (coinType => address)
    mapping(bytes32 => mapping(uint256 => bytes)) private coinAddresses;

    // Mapping from node to name (for reverse resolution)
    mapping(bytes32 => string) private names;

    // Mapping from node to text records (key => value)
    mapping(bytes32 => mapping(string => string)) private texts;

    // Mapping from node to content hash
    mapping(bytes32 => bytes) private contentHashes;

    // Coin types for multi-chain support
    uint256 constant COIN_TYPE_ETH = 60;
    uint256 constant COIN_TYPE_BTC = 0;
    uint256 constant COIN_TYPE_SOL = 501;

    /**
     * @dev Constructor
     * @param registry_ The address of the MIDL registry
     */
    constructor(address registry_) {
        registry = IMIDLRegistry(registry_);
    }

    /**
     * @dev Modifier to restrict access to node owners
     */
    modifier authorised(bytes32 node) {
        require(
            registry.owner(node) == msg.sender,
            "MIDLResolver: Not authorised"
        );
        _;
    }

    // ============ Address Resolution ============

    /**
     * @dev Get the ETH address for a node
     * @param node The node to query
     * @return The ETH address
     */
    function addr(bytes32 node) external view returns (address payable) {
        return payable(addresses[node]);
    }

    /**
     * @dev Get the address for a node for a specific coin type
     * @param node The node to query
     * @param coinType The coin type (SLIP-0044)
     * @return The address in bytes
     */
    function addr(bytes32 node, uint256 coinType) external view returns (bytes memory) {
        if (coinType == COIN_TYPE_ETH) {
            return abi.encodePacked(addresses[node]);
        }
        return coinAddresses[node][coinType];
    }

    /**
     * @dev Set the ETH address for a node
     * @param node The node to update
     * @param a The new ETH address
     */
    function setAddr(bytes32 node, address a) external authorised(node) {
        addresses[node] = a;
        emit AddrChanged(node, a);
    }

    /**
     * @dev Set the address for a node for a specific coin type
     * @param node The node to update
     * @param coinType The coin type (SLIP-0044)
     * @param a The new address
     */
    function setAddr(bytes32 node, uint256 coinType, bytes calldata a) external authorised(node) {
        if (coinType == COIN_TYPE_ETH) {
            require(a.length == 20, "MIDLResolver: Invalid ETH address");
            addresses[node] = address(uint160(bytes20(a)));
            emit AddrChanged(node, address(uint160(bytes20(a))));
        } else {
            coinAddresses[node][coinType] = a;
        }
        emit AddressChanged(node, coinType, a);
    }

    // ============ Name Resolution (Reverse) ============

    /**
     * @dev Get the name for a node (reverse resolution)
     * @param node The node to query
     * @return The name string
     */
    function name(bytes32 node) external view returns (string memory) {
        return names[node];
    }

    /**
     * @dev Set the name for a node
     * @param node The node to update
     * @param name_ The new name
     */
    function setName(bytes32 node, string calldata name_) external authorised(node) {
        names[node] = name_;
        emit NameChanged(node, name_);
    }

    // ============ Text Records ============

    /**
     * @dev Get a text record for a node
     * @param node The node to query
     * @param key The key of the text record
     * @return The value string
     */
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return texts[node][key];
    }

    /**
     * @dev Set a text record for a node
     * @param node The node to update
     * @param key The key of the text record
     * @param value The new value
     */
    function setText(bytes32 node, string calldata key, string calldata value) external authorised(node) {
        texts[node][key] = value;
        emit TextChanged(node, key, key, value);
    }

    // ============ Content Hash ============

    /**
     * @dev Get the content hash for a node
     * @param node The node to query
     * @return The content hash
     */
    function contenthash(bytes32 node) external view returns (bytes memory) {
        return contentHashes[node];
    }

    /**
     * @dev Set the content hash for a node
     * @param node The node to update
     * @param hash The new content hash
     */
    function setContenthash(bytes32 node, bytes calldata hash) external authorised(node) {
        contentHashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }

    // ============ Interface Support ============

    /**
     * @dev Check if this contract supports a given interface
     * @param interfaceID The interface identifier
     * @return True if supported
     */
    function supportsInterface(bytes4 interfaceID) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceID == type(IMIDLResolver).interfaceId ||
            super.supportsInterface(interfaceID);
    }
}