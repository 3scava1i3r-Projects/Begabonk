// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/StringUtils.sol";
import "./libraries/Base64.sol";
import "./interfaces/IMIDLRegistry.sol";
import "./interfaces/IMIDLResolver.sol";
import "./MIDLResolver.sol";

/**
 * @title MIDLDomain
 * @dev NFT contract for .midl domain names with on-chain SVG generation
 */
contract MIDLDomain is ERC721URIStorage, Ownable {
    using StringUtils for string;

    uint256 private _tokenIds;

    // TLD for this domain service
    string public constant TLD = "midl";

    // Registry contract
    IMIDLRegistry public registry;

    // Default resolver
    MIDLResolver public defaultResolver;

    // Namehash of the TLD - computed as keccak256(abi.encodePacked(bytes32(0), keccak256("midl")))
    bytes32 public immutable TLD_NODE;

    // Mapping from name to owner address
    mapping(string => address) public nameOwners;

    // Mapping from name to token ID
    mapping(string => uint256) public nameToTokenId;

    // Mapping from token ID to name
    mapping(uint256 => string) public tokenIdToName;

    // Price tiers based on name length
    uint256 public constant PRICE_3_CHARS = 0.05 ether;
    uint256 public constant PRICE_4_CHARS = 0.03 ether;
    uint256 public constant PRICE_5_PLUS_CHARS = 0.01 ether;

    // Events
    event NameRegistered(string name, address indexed owner, uint256 tokenId, uint256 price);
    event NameTransferred(string name, address indexed from, address indexed to);

    // Errors
    error NameNotAvailable(string name);
    error InvalidName(string name);
    error InsufficientPayment(uint256 required, uint256 provided);
    error Unauthorized();

    // SVG Parts for on-chain NFT image
    string private constant SVG_PART_ONE = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#gradient)" d="M0 0h270v270H0z"/><defs><linearGradient id="gradient" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#6366f1"/><stop offset="1" stop-color="#8b5cf6"/></linearGradient></defs><rect x="20" y="20" width="230" height="230" rx="20" fill="rgba(255,255,255,0.1)"/><text x="135" y="135" text-anchor="middle" dominant-baseline="middle" font-size="28" fill="white" font-family="Arial, sans-serif" font-weight="bold">';
    string private constant SVG_PART_TWO = '</text><text x="135" y="200" text-anchor="middle" font-size="14" fill="rgba(255,255,255,0.7)" font-family="Arial, sans-serif">powered by MIDL</text></svg>';

    constructor(
        address registry_,
        address resolver_
    ) ERC721("MIDL Name Service", "MIDL") Ownable(msg.sender) {
        registry = IMIDLRegistry(registry_);
        defaultResolver = MIDLResolver(resolver_);
        
        // Compute TLD_NODE: keccak256(abi.encodePacked(bytes32(0), keccak256("midl")))
        TLD_NODE = keccak256(abi.encodePacked(bytes32(0), keccak256(bytes(TLD))));
    }

    /**
     * @dev Register a new .midl domain name
     * @param name The name to register (without .midl)
     */
    function register(string calldata name) external payable {
        string memory lowerName = name.toLower();

        // Validate name
        if (!_isValidName(lowerName)) {
            revert InvalidName(name);
        }

        // Check availability
        if (nameOwners[lowerName] != address(0)) {
            revert NameNotAvailable(name);
        }

        // Check price
        uint256 price = getPrice(lowerName);
        if (msg.value < price) {
            revert InsufficientPayment(price, msg.value);
        }

        // Mint NFT
        uint256 newTokenId = _tokenIds;
        _safeMint(msg.sender, newTokenId);

        // Generate token URI
        string memory tokenURI = _generateTokenURI(lowerName);
        _setTokenURI(newTokenId, tokenURI);

        // Update mappings
        nameOwners[lowerName] = msg.sender;
        nameToTokenId[lowerName] = newTokenId;
        tokenIdToName[newTokenId] = lowerName;

        // Register in the registry
        bytes32 label = keccak256(abi.encodePacked(lowerName));
        bytes32 node = keccak256(abi.encodePacked(TLD_NODE, label));
        
        // First set ourselves as the owner so we can configure the node
        registry.setSubnodeOwner(TLD_NODE, label, address(this));

        // Set default resolver
        registry.setResolver(node, address(defaultResolver));

        // Set default address in resolver
        defaultResolver.setAddr(node, msg.sender);
        
        // Now transfer ownership to the user
        registry.setOwner(node, msg.sender);

        _tokenIds++;

        emit NameRegistered(lowerName, msg.sender, newTokenId, price);

        // Refund excess payment
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    /**
     * @dev Get the price for a name based on length
     * @param name The name to check
     * @return The price in wei
     */
    function getPrice(string memory name) public pure returns (uint256) {
        uint256 len = name.strlen();
        require(len >= 3, "Name too short");
        require(len <= 50, "Name too long");

        if (len == 3) {
            return PRICE_3_CHARS;
        } else if (len == 4) {
            return PRICE_4_CHARS;
        } else {
            return PRICE_5_PLUS_CHARS;
        }
    }

    /**
     * @dev Check if a name is available
     * @param name The name to check
     * @return True if available
     */
    function available(string calldata name) external view returns (bool) {
        string memory lowerName = name.toLower();
        return _isValidName(lowerName) && nameOwners[lowerName] == address(0);
    }

    /**
     * @dev Get the owner of a name
     * @param name The name to query
     * @return The owner address
     */
    function getOwner(string calldata name) external view returns (address) {
        return nameOwners[name.toLower()];
    }

    /**
     * @dev Get all registered names (for frontend)
     * @return Array of all registered names
     */
    function getAllNames() external view returns (string[] memory) {
        uint256 total = _tokenIds;
        string[] memory allNames = new string[](total);
        for (uint256 i = 0; i < total; i++) {
            allNames[i] = tokenIdToName[i];
        }
        return allNames;
    }

    /**
     * @dev Get the node for a name
     * @param name The name to convert
     * @return The bytes32 node
     */
    function getNameNode(string calldata name) external view returns (bytes32) {
        string memory lowerName = name.toLower();
        bytes32 label = keccak256(abi.encodePacked(lowerName));
        return keccak256(abi.encodePacked(TLD_NODE, label));
    }

    /**
     * @dev Transfer a name to another address
     * @param to The new owner
     * @param name The name to transfer
     */
    function transferName(address to, string calldata name) external {
        string memory lowerName = name.toLower();
        if (nameOwners[lowerName] != msg.sender) {
            revert Unauthorized();
        }

        uint256 tokenId = nameToTokenId[lowerName];
        _transfer(msg.sender, to, tokenId);

        nameOwners[lowerName] = to;

        // Note: Registry ownership stays with original owner for resolver operations
        // The domain contract tracks ownership via nameOwners mapping and NFT

        emit NameTransferred(lowerName, msg.sender, to);
    }

    /**
     * @dev Set resolver for a name
     * @param name The name to update
     * @param resolver_ The new resolver address
     */
    function setResolver(string calldata name, address resolver_) external {
        string memory lowerName = name.toLower();
        if (nameOwners[lowerName] != msg.sender) {
            revert Unauthorized();
        }

        bytes32 label = keccak256(abi.encodePacked(lowerName));
        bytes32 node = keccak256(abi.encodePacked(TLD_NODE, label));
        registry.setResolver(node, resolver_);
    }

    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    // ============ Internal Functions ============

    /**
     * @dev Validate a name
     */
    function _isValidName(string memory name) internal pure returns (bool) {
        uint256 len = name.strlen();
        if (len < 3 || len > 50) {
            return false;
        }
        return name.isAlphanumeric();
    }

    /**
     * @dev Generate the token URI for an NFT
     */
    function _generateTokenURI(string memory name) internal pure returns (string memory) {
        string memory fullName = string(abi.encodePacked(name, ".", TLD));

        // Generate SVG
        string memory svg = string(abi.encodePacked(SVG_PART_ONE, fullName, SVG_PART_TWO));

        // Generate JSON metadata
        string memory json = string(
            abi.encodePacked(
                '{"name": "',
                fullName,
                '", "description": "A .midl domain name on the MIDL Name Service", ',
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(svg)),
                '", "attributes": [',
                '{"trait_type": "Length", "value": "',
                StringUtils.toString(name.strlen()),
                '"}]}'
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    // ============ View Functions ============

    /**
     * @dev Get total number of registered names
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIds;
    }

    /**
     * @dev Get name by token ID
     */
    function getNameByTokenId(uint256 tokenId) external view returns (string memory) {
        return tokenIdToName[tokenId];
    }

    /**
     * @dev Get token ID by name
     */
    function getTokenIdByName(string calldata name) external view returns (uint256) {
        return nameToTokenId[name.toLower()];
    }
}