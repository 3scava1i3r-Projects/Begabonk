// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IMIDLOrder
 * @dev Interface for the MIDL Order - purchase order management
 */
interface IMIDLOrder {
    // Order status enum
    enum OrderStatus {
        Pending,
        Paid,
        Shipped,
        Delivered,
        Cancelled,
        Refunded
    }

    // Order structure
    struct Order {
        uint256 id;
        uint256 productId;
        string channelName;
        address buyer;
        address seller;
        uint256 quantity;
        uint256 totalPrice;
        OrderStatus status;
        string shippingAddress;
        string shippingData; // JSON string for additional shipping info
        uint256 createdAt;
        uint256 updatedAt;
    }

    // Events
    event OrderCreated(
        uint256 indexed orderId,
        uint256 indexed productId,
        string channelName,
        address indexed buyer,
        address seller,
        uint256 quantity,
        uint256 totalPrice
    );
    event OrderPaid(
        uint256 indexed orderId,
        address indexed buyer,
        uint256 amount
    );
    event OrderShipped(
        uint256 indexed orderId,
        string trackingNumber
    );
    event OrderDelivered(
        uint256 indexed orderId
    );
    event OrderCancelled(
        uint256 indexed orderId,
        address indexed canceller
    );
    event OrderRefunded(
        uint256 indexed orderId,
        address indexed refundedTo,
        uint256 amount
    );

    // Functions
    function createOrder(
        uint256 productId,
        string calldata channelName,
        address seller,
        uint256 quantity,
        string calldata shippingAddress,
        string calldata shippingData
    ) external payable returns (uint256);

    function payOrder(uint256 orderId) external payable;

    function shipOrder(uint256 orderId, string calldata trackingNumber) external;

    function deliverOrder(uint256 orderId) external;

    function cancelOrder(uint256 orderId) external;

    function refundOrder(uint256 orderId) external;

    function getOrder(uint256 orderId) external view returns (Order memory);

    function getOrdersByBuyer(address buyer)
        external
        view
        returns (Order[] memory);

    function getOrdersBySeller(address seller)
        external
        view
        returns (Order[] memory);

    function getOrdersByChannel(string calldata channelName)
        external
        view
        returns (Order[] memory);

    function getOrderCount() external view returns (uint256);
}
