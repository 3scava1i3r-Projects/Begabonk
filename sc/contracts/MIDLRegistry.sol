// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMIDLRegistry.sol";

/**
 * @title MIDLRegistry
 * @dev A registry contract for the MIDL naming service, similar to ENS registry.
 * Stores ownership and resolver mappings for domain nodes.
 */
contract MIDLRegistry is IMIDLRegistry, Ownable {
    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    // Root node for .midl TLD
    bytes32 public constant ROOT_NODE = bytes32(0);

    // Mapping from node to record
    mapping(bytes32 => Record) private records;

    // Mapping for approved operators
    mapping(address => mapping(address => bool)) private operators;

    // Events
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Constructor sets the owner of the root node
     */
    constructor() Ownable(msg.sender) {
        records[ROOT_NODE].owner = msg.sender;
    }

    /**
     * @dev Modifier to restrict access to node owners
     */
    modifier authorised(bytes32 node) {
        address currentOwner = records[node].owner;
        require(
            currentOwner == msg.sender ||
                operators[currentOwner][msg.sender],
            "MIDLRegistry: Not authorised"
        );
        _;
    }

    /**
     * @dev Set the owner of a node
     * @param node The node to change ownership of
     * @param owner The new owner of the node
     */
    function setOwner(bytes32 node, address owner) external authorised(node) {
        _setOwner(node, owner);
        emit Transfer(node, owner);
    }

    /**
     * @dev Set the owner of a subnode
     * @param node The parent node
     * @param label The label of the subnode
     * @param owner The new owner of the subnode
     * @return The bytes32 representation of the subnode
     */
    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address owner
    ) external authorised(node) returns (bytes32) {
        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        _setOwner(subnode, owner);
        emit NewOwner(node, label, owner);
        return subnode;
    }

    /**
     * @dev Set the resolver for a node
     * @param node The node to set the resolver for
     * @param resolver The address of the resolver
     */
    function setResolver(bytes32 node, address resolver) external authorised(node) {
        records[node].resolver = resolver;
        emit NewResolver(node, resolver);
    }

    /**
     * @dev Set the TTL for a node
     * @param node The node to set the TTL for
     * @param ttl The TTL in seconds
     */
    function setTTL(bytes32 node, uint64 ttl) external authorised(node) {
        records[node].ttl = ttl;
        emit NewTTL(node, ttl);
    }

    /**
     * @dev Set or clear approval for an operator
     * @param operator The operator address
     * @param approved Whether to approve or revoke
     */
    function setApprovalForAll(address operator, bool approved) external {
        operators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev Get the owner of a node
     * @param node The node to query
     * @return The owner address
     */
    function owner(bytes32 node) external view returns (address) {
        return records[node].owner;
    }

    /**
     * @dev Get the resolver for a node
     * @param node The node to query
     * @return The resolver address
     */
    function resolver(bytes32 node) external view returns (address) {
        return records[node].resolver;
    }

    /**
     * @dev Get the TTL for a node
     * @param node The node to query
     * @return The TTL in seconds
     */
    function ttl(bytes32 node) external view returns (uint64) {
        return records[node].ttl;
    }

    /**
     * @dev Check if a record exists for a node
     * @param node The node to query
     * @return True if the record exists
     */
    function recordExists(bytes32 node) external view returns (bool) {
        return records[node].owner != address(0);
    }

    /**
     * @dev Check if an address is an authorized operator for an owner
     * @param owner_ The owner address
     * @param operator The operator address
     * @return True if authorized
     */
    function isApprovedForAll(address owner_, address operator) external view returns (bool) {
        return operators[owner_][operator];
    }

    // Internal functions

    function _setOwner(bytes32 node, address owner_) internal {
        records[node].owner = owner_;
    }
}