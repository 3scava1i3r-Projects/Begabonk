// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IMIDLOrder.sol";
import "./interfaces/IMIDLStore.sol";
import "./libraries/StringUtils.sol";

/**
 * @title MIDLOrder
 * @dev Order management contract for MIDL commerce
 * Handles purchase orders, payments, and fulfillment
 */
contract MIDLOrder is IMIDLOrder, Ownable, ReentrancyGuard {
    using StringUtils for string;

    // Order counter
    uint256 private _orderIds;

    // Store contract reference
    IMIDLStore public store;

    // Mapping from order ID to Order
    mapping(uint256 => Order) public orders;

    // Mapping from buyer address to order IDs
    mapping(address => uint256[]) private _buyerOrders;

    // Mapping from seller address to order IDs
    mapping(address => uint256[]) private _sellerOrders;

    // Mapping from channel name to order IDs
    mapping(string => uint256[]) private _channelOrders;

    // Platform fee percentage (e.g., 250 = 2.5%)
    uint256 public constant PLATFORM_FEE_PERCENT = 250;

    // Errors
    error OrderNotFound(uint256 orderId);
    error Unauthorized(address caller);
    error InvalidQuantity(uint256 quantity);
    error InsufficientPayment(uint256 required, uint256 provided);
    error InvalidOrderState(OrderStatus current, OrderStatus[] allowed);
    error TransferFailed(address to, uint256 amount);

    // Modifiers
    modifier onlyBuyer(uint256 orderId) {
        if (orders[orderId].buyer != msg.sender) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    modifier onlySeller(uint256 orderId) {
        if (orders[orderId].seller != msg.sender) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    modifier orderExists(uint256 orderId) {
        if (orderId == 0 || orderId > _orderIds) {
            revert OrderNotFound(orderId);
        }
        _;
    }

    constructor(address _store) Ownable(msg.sender) {
        require(_store != address(0), "Invalid store address");
        store = IMIDLStore(_store);
    }

    /**
     * @dev Create a new order
     * @param productId The product ID being purchased
     * @param channelName The seller's channel name
     * @param seller The seller's wallet address
     * @param quantity Quantity being purchased
     * @param shippingAddress Shipping address
     * @param shippingData Additional shipping data (JSON)
     * @return The new order ID
     */
    function createOrder(
        uint256 productId,
        string calldata channelName,
        address seller,
        uint256 quantity,
        string calldata shippingAddress,
        string calldata shippingData
    ) external payable override returns (uint256) {
        require(quantity > 0, "Quantity must be greater than 0");
        require(bytes(shippingAddress).length > 0, "Shipping address required");

        // Get product details from store
        IMIDLStore.Product memory product = store.getProduct(productId);

        // Verify product is active
        require(product.isActive, "Product not active");

        // Verify stock
        require(product.stock >= quantity, "Insufficient stock");

        // Calculate total price
        uint256 totalPrice = product.price * quantity;

        // Check payment (if paid immediately)
        // For this implementation, we'll support both:
        // 1. Pay on creation (msg.value >= totalPrice)
        // 2. Pay later via payOrder
        if (msg.value > 0) {
            require(msg.value >= totalPrice, "Insufficient payment");
        }

        // Create order
        _orderIds++;
        uint256 newOrderId = _orderIds;

        OrderStatus initialStatus = msg.value >= totalPrice
            ? OrderStatus.Paid
            : OrderStatus.Pending;

        Order memory order = Order({
            id: newOrderId,
            productId: productId,
            channelName: channelName.toLower(),
            buyer: msg.sender,
            seller: seller,
            quantity: quantity,
            totalPrice: totalPrice,
            status: initialStatus,
            shippingAddress: shippingAddress,
            shippingData: shippingData,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        // Store order
        orders[newOrderId] = order;

        // Update mappings
        _buyerOrders[msg.sender].push(newOrderId);
        _sellerOrders[seller].push(newOrderId);
        _channelOrders[channelName.toLower()].push(newOrderId);

        // Reduce stock in store
        if (msg.value >= totalPrice) {
            store.reduceStock(productId, quantity);
        }

        // Handle payment if provided
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }

        emit OrderCreated(
            newOrderId,
            productId,
            channelName.toLower(),
            msg.sender,
            seller,
            quantity,
            totalPrice
        );

        if (msg.value >= totalPrice) {
            emit OrderPaid(newOrderId, msg.sender, totalPrice);
        }

        return newOrderId;
    }

    /**
     * @dev Pay for an order (if not paid on creation)
     * @param orderId The order ID
     */
    function payOrder(uint256 orderId)
        external
        payable
        override
        onlyBuyer(orderId)
        orderExists(orderId)
        nonReentrant
    {
        Order storage order = orders[orderId];

        // Check order status
        if (order.status != OrderStatus.Pending) {
            revert InvalidOrderState(order.status, _allowedStates(order.status));
        }

        // Verify payment
        if (msg.value < order.totalPrice) {
            revert InsufficientPayment(order.totalPrice, msg.value);
        }

        // Update status
        order.status = OrderStatus.Paid;
        order.updatedAt = block.timestamp;

        // Reduce stock
        store.reduceStock(order.productId, order.quantity);

        // Refund excess payment
        if (msg.value > order.totalPrice) {
            payable(msg.sender).transfer(msg.value - order.totalPrice);
        }

        emit OrderPaid(orderId, msg.sender, order.totalPrice);
    }

    /**
     * @dev Mark order as shipped
     * @param orderId The order ID
     * @param trackingNumber Tracking number from shipping provider
     */
    function shipOrder(uint256 orderId, string calldata trackingNumber)
        external
        override
        onlySeller(orderId)
        orderExists(orderId)
    {
        Order storage order = orders[orderId];

        if (order.status != OrderStatus.Paid) {
            revert InvalidOrderState(order.status, _allowedStates(order.status));
        }

        order.status = OrderStatus.Shipped;
        order.updatedAt = block.timestamp;

        emit OrderShipped(orderId, trackingNumber);
    }

    /**
     * @dev Mark order as delivered
     * @param orderId The order ID
     */
    function deliverOrder(uint256 orderId)
        external
        override
        onlyBuyer(orderId)
        orderExists(orderId)
    {
        Order storage order = orders[orderId];

        if (order.status != OrderStatus.Shipped) {
            revert InvalidOrderState(order.status, _allowedStates(order.status));
        }

        order.status = OrderStatus.Delivered;
        order.updatedAt = block.timestamp;

        // Transfer funds to seller (minus platform fee)
        _transferToSeller(order.seller, order.totalPrice);

        emit OrderDelivered(orderId);
    }

    /**
     * @dev Cancel an order (only pending orders)
     * @param orderId The order ID
     */
    function cancelOrder(uint256 orderId)
        external
        override
        orderExists(orderId)
    {
        Order storage order = orders[orderId];

        // Only buyer or seller can cancel
        if (msg.sender != order.buyer && msg.sender != order.seller) {
            revert Unauthorized(msg.sender);
        }

        // Only pending or paid orders can be cancelled
        if (order.status != OrderStatus.Pending && order.status != OrderStatus.Paid) {
            revert InvalidOrderState(order.status, _allowedStates(order.status));
        }

        order.status = OrderStatus.Cancelled;
        order.updatedAt = block.timestamp;

        emit OrderCancelled(orderId, msg.sender);
    }

    /**
     * @dev Refund an order (only seller or owner)
     * @param orderId The order ID
     */
    function refundOrder(uint256 orderId)
        external
        override
        onlySeller(orderId)
        orderExists(orderId)
        nonReentrant
    {
        Order storage order = orders[orderId];

        if (order.status != OrderStatus.Paid && order.status != OrderStatus.Shipped) {
            revert InvalidOrderState(order.status, _allowedStates(order.status));
        }

        // Refund buyer
        (bool success, ) = payable(order.buyer).call{value: order.totalPrice}("");
        if (!success) {
            revert TransferFailed(order.buyer, order.totalPrice);
        }

        order.status = OrderStatus.Refunded;
        order.updatedAt = block.timestamp;

        emit OrderRefunded(orderId, order.buyer, order.totalPrice);
    }

    /**
     * @dev Get order by ID
     * @param orderId The order ID
     * @return Order struct
     */
    function getOrder(uint256 orderId)
        external
        view
        override
        orderExists(orderId)
        returns (Order memory)
    {
        return orders[orderId];
    }

    /**
     * @dev Get all orders for a buyer
     * @param buyer The buyer's address
     * @return Array of Order structs
     */
    function getOrdersByBuyer(address buyer)
        external
        view
        override
        returns (Order[] memory)
    {
        uint256[] storage orderIds = _buyerOrders[buyer];
        Order[] memory result = new Order[](orderIds.length);

        for (uint256 i = 0; i < orderIds.length; i++) {
            result[i] = orders[orderIds[i]];
        }

        return result;
    }

    /**
     * @dev Get all orders for a seller
     * @param seller The seller's address
     * @return Array of Order structs
     */
    function getOrdersBySeller(address seller)
        external
        view
        override
        returns (Order[] memory)
    {
        uint256[] storage orderIds = _sellerOrders[seller];
        Order[] memory result = new Order[](orderIds.length);

        for (uint256 i = 0; i < orderIds.length; i++) {
            result[i] = orders[orderIds[i]];
        }

        return result;
    }

    /**
     * @dev Get all orders for a channel
     * @param channelName The channel name
     * @return Array of Order structs
     */
    function getOrdersByChannel(string calldata channelName)
        external
        view
        override
        returns (Order[] memory)
    {
        string memory lowerChannel = channelName.toLower();
        uint256[] storage orderIds = _channelOrders[lowerChannel];
        Order[] memory result = new Order[](orderIds.length);

        for (uint256 i = 0; i < orderIds.length; i++) {
            result[i] = orders[orderIds[i]];
        }

        return result;
    }

    /**
     * @dev Get total order count
     * @return Total number of orders
     */
    function getOrderCount() external view override returns (uint256) {
        return _orderIds;
    }

    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Internal functions

    function _transferToSeller(address seller, uint256 amount) internal {
        // Calculate platform fee
        uint256 platformFee = (amount * PLATFORM_FEE_PERCENT) / 10000;
        uint256 sellerAmount = amount - platformFee;

        (bool success, ) = payable(seller).call{value: sellerAmount}("");
        if (!success) {
            revert TransferFailed(seller, sellerAmount);
        }
    }

    function _allowedStates(OrderStatus current)
        internal
        pure
        returns (OrderStatus[] memory)
    {
        // This is a helper for error messages
        // Actual validation happens in each function
        OrderStatus[] memory allowed;
        return allowed;
    }

    // Receive ETH
    receive() external payable {}
}
