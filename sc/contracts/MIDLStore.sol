// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMIDLStore.sol";
import "./libraries/StringUtils.sol";

/**
 * @title MIDLStore
 * @dev Product management contract for MIDL channel names
 * Allows sellers to create, update, and manage products tied to their channel names
 */
contract MIDLStore is IMIDLStore, Ownable {
    using StringUtils for string;

    // Product counter
    uint256 private _productIds;

    // Mapping from product ID to Product struct
    mapping(uint256 => Product) public products;

    // Mapping from channel name to product IDs
    mapping(string => uint256[]) private _channelProductIds;

    // Mapping from product ID to channel name
    mapping(uint256 => string) private _productChannelName;

    // Mapping from product ID to seller (creator of product)
    mapping(uint256 => address) private _productSeller;

    // TLD constant for validation
    string public constant TLD = "midl";

    // Errors
    error ProductNotFound(uint256 productId);
    error Unauthorized(address caller);
    error InvalidPrice(uint256 price);
    error InsufficientStock(uint256 requested, uint256 available);
    error ProductNotActive(uint256 productId);

    // Modifiers
    modifier onlyProductSeller(uint256 productId) {
        if (_productSeller[productId] != msg.sender) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    modifier productExists(uint256 productId) {
        if (productId == 0 || productId > _productIds) {
            revert ProductNotFound(productId);
        }
        _;
    }

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Create a new product for a channel
     * @param channelName The channel name (e.g., "mystore.midl")
     * @param name Product name
     * @param description Product description
     * @param imageURI IPFS URI for product image
     * @param price Price in wei
     * @param stock Available stock quantity
     * @return The new product ID
     */
    function createProduct(
        string calldata channelName,
        string calldata name,
        string calldata description,
        string calldata imageURI,
        uint256 price,
        uint256 stock
    ) external override returns (uint256) {
        // Validate inputs
        require(bytes(name).length > 0, "Product name required");
        require(price > 0, "Price must be greater than 0");

        // Generate product ID
        _productIds++;
        uint256 newProductId = _productIds;

        // Create product
        Product memory product = Product({
            id: newProductId,
            name: name,
            description: description,
            imageURI: imageURI,
            price: price,
            stock: stock,
            isActive: true,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        // Store product
        products[newProductId] = product;

        // Store channel name (lowercase)
        string memory lowerChannel = channelName.toLower();
        _productChannelName[newProductId] = lowerChannel;
        _productSeller[newProductId] = msg.sender;

        // Add to channel's product list
        _channelProductIds[lowerChannel].push(newProductId);

        emit ProductCreated(
            newProductId,
            lowerChannel,
            msg.sender,
            name,
            price
        );

        return newProductId;
    }

    /**
     * @dev Update an existing product
     * @param productId The product ID to update
     * @param name New product name
     * @param description New description
     * @param imageURI New image URI
     * @param price New price
     * @param stock New stock
     * @param isActive Whether product is active
     */
    function updateProduct(
        uint256 productId,
        string calldata name,
        string calldata description,
        string calldata imageURI,
        uint256 price,
        uint256 stock,
        bool isActive
    ) external override onlyProductSeller(productId) productExists(productId) {
        require(bytes(name).length > 0, "Product name required");
        require(price > 0, "Price must be greater than 0");

        Product storage product = products[productId];
        product.name = name;
        product.description = description;
        product.imageURI = imageURI;
        product.price = price;
        product.stock = stock;
        product.isActive = isActive;
        product.updatedAt = block.timestamp;

        string memory channelName = _productChannelName[productId];

        emit ProductUpdated(
            productId,
            channelName,
            msg.sender,
            price,
            stock
        );
    }

    /**
     * @dev Delete a product (soft delete by setting inactive)
     * @param productId The product ID to delete
     */
    function deleteProduct(uint256 productId)
        external
        override
        onlyProductSeller(productId)
        productExists(productId)
    {
        Product storage product = products[productId];
        product.isActive = false;
        product.updatedAt = block.timestamp;

        string memory channelName = _productChannelName[productId];

        emit ProductDeleted(productId, channelName, msg.sender);
    }

    /**
     * @dev Get product by ID
     * @param productId The product ID
     * @return Product struct
     */
    function getProduct(uint256 productId)
        external
        view
        override
        productExists(productId)
        returns (Product memory)
    {
        return products[productId];
    }

    /**
     * @dev Get all products for a channel
     * @param channelName The channel name
     * @return Array of Product structs
     */
    function getProductsByChannel(string calldata channelName)
        external
        view
        override
        returns (Product[] memory)
    {
        string memory lowerChannel = channelName.toLower();
        uint256[] storage productIds = _channelProductIds[lowerChannel];
        Product[] memory result = new Product[](productIds.length);

        for (uint256 i = 0; i < productIds.length; i++) {
            result[i] = products[productIds[i]];
        }

        return result;
    }

    /**
     * @dev Get only active products for a channel
     * @param channelName The channel name
     * @return Array of active Product structs
     */
    function getActiveProductsByChannel(string calldata channelName)
        external
        view
        override
        returns (Product[] memory)
    {
        string memory lowerChannel = channelName.toLower();
        uint256[] storage productIds = _channelProductIds[lowerChannel];

        // First pass: count active products
        uint256 activeCount = 0;
        for (uint256 i = 0; i < productIds.length; i++) {
            if (products[productIds[i]].isActive) {
                activeCount++;
            }
        }

        // Second pass: populate array
        Product[] memory result = new Product[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < productIds.length; i++) {
            Product memory product = products[productIds[i]];
            if (product.isActive) {
                result[index] = product;
                index++;
            }
        }

        return result;
    }

    /**
     * @dev Reduce stock after purchase
     * @param productId The product ID
     * @param quantity Amount to reduce
     */
    function reduceStock(uint256 productId, uint256 quantity)
        external
        override
        productExists(productId)
    {
        Product storage product = products[productId];

        if (!product.isActive) {
            revert ProductNotActive(productId);
        }

        if (product.stock < quantity) {
            revert InsufficientStock(quantity, product.stock);
        }

        product.stock -= quantity;
        product.updatedAt = block.timestamp;

        emit ProductStockReduced(
            productId,
            _productChannelName[productId],
            quantity
        );
    }

    /**
     * @dev Check if a product is active
     * @param productId The product ID
     * @return True if active
     */
    function isProductActive(uint256 productId)
        external
        view
        override
        productExists(productId)
        returns (bool)
    {
        return products[productId].isActive;
    }

    /**
     * @dev Get seller of a product
     * @param productId The product ID
     * @return Seller address
     */
    function getProductSeller(uint256 productId)
        external
        view
        productExists(productId)
        returns (address)
    {
        return _productSeller[productId];
    }

    /**
     * @dev Get total product count
     * @return Total number of products
     */
    function totalProducts() external view returns (uint256) {
        return _productIds;
    }
}
