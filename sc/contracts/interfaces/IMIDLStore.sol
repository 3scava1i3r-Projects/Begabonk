// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IMIDLStore
 * @dev Interface for the MIDL Store - product management for channel names
 */
interface IMIDLStore {
    // Product structure
    struct Product {
        uint256 id;
        string name;
        string description;
        string imageURI;
        uint256 price; // in wei
        uint256 stock;
        bool isActive;
        uint256 createdAt;
        uint256 updatedAt;
    }

    // Events
    event ProductCreated(
        uint256 indexed productId,
        string indexed channelName,
        address indexed seller,
        string name,
        uint256 price
    );
    event ProductUpdated(
        uint256 indexed productId,
        string indexed channelName,
        address indexed seller,
        uint256 price,
        uint256 stock
    );
    event ProductDeleted(
        uint256 indexed productId,
        string indexed channelName,
        address indexed seller
    );
    event ProductStockReduced(
        uint256 indexed productId,
        string indexed channelName,
        uint256 quantity
    );

    // Functions
    function createProduct(
        string calldata channelName,
        string calldata name,
        string calldata description,
        string calldata imageURI,
        uint256 price,
        uint256 stock
    ) external returns (uint256);

    function updateProduct(
        uint256 productId,
        string calldata name,
        string calldata description,
        string calldata imageURI,
        uint256 price,
        uint256 stock,
        bool isActive
    ) external;

    function deleteProduct(uint256 productId) external;

    function getProduct(uint256 productId) external view returns (Product memory);

    function getProductsByChannel(string calldata channelName)
        external
        view
        returns (Product[] memory);

    function getActiveProductsByChannel(string calldata channelName)
        external
        view
        returns (Product[] memory);

    function reduceStock(uint256 productId, uint256 quantity) external;

    function isProductActive(uint256 productId) external view returns (bool);
}
