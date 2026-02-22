// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMIDLReview.sol";
import "./interfaces/IMIDLOrder.sol";
import "./libraries/StringUtils.sol";

/**
 * @title MIDLReview
 * @dev Verified review system for MIDL commerce
 * Only buyers who completed a purchase can leave reviews
 */
contract MIDLReview is IMIDLReview, Ownable {
    using StringUtils for string;

    // Review counter
    uint256 private _reviewIds;

    // Order contract reference
    IMIDLOrder public orderContract;

    // Mapping from review ID to Review
    mapping(uint256 => Review) public reviews;

    // Mapping from order ID to review ID (one review per order)
    mapping(uint256 => uint256) private _orderReviewId;

    // Mapping from product ID to review IDs
    mapping(uint256 => uint256[]) private _productReviews;

    // Mapping from channel name to review IDs
    mapping(string => uint256[]) private _channelReviews;

    // Mapping from reviewer address to review IDs
    mapping(address => uint256[]) private _reviewerReviews;

    // Errors
    error ReviewNotFound(uint256 reviewId);
    error Unauthorized(address caller);
    error InvalidRating(uint8 rating);
    error OrderNotVerified(uint256 orderId);
    error AlreadyReviewed(uint256 orderId);
    error OrderNotDelivered(uint256 orderId);

    // Modifiers
    modifier onlyReviewer(uint256 reviewId) {
        if (reviews[reviewId].reviewer != msg.sender) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    modifier reviewExists(uint256 reviewId) {
        if (reviewId == 0 || reviewId > _reviewIds) {
            revert ReviewNotFound(reviewId);
        }
        if (!reviews[reviewId].exists) {
            revert ReviewNotFound(reviewId);
        }
        _;
    }

    constructor(address _orderContract) Ownable(msg.sender) {
        require(_orderContract != address(0), "Invalid order contract");
        orderContract = IMIDLOrder(_orderContract);
    }

    /**
     * @dev Create a new review (only buyer who completed purchase)
     * @param orderId The order ID to review
     * @param productId The product ID
     * @param channelName The channel name
     * @param rating Rating 1-5
     * @param comment Review comment
     * @return The new review ID
     */
    function createReview(
        uint256 orderId,
        uint256 productId,
        string calldata channelName,
        uint8 rating,
        string calldata comment
    ) external override returns (uint256) {
        // Validate rating
        if (rating < 1 || rating > 5) {
            revert InvalidRating(rating);
        }

        // Verify the order exists and buyer is msg.sender
        IMIDLOrder.Order memory order = orderContract.getOrder(orderId);

        if (order.buyer != msg.sender) {
            revert Unauthorized(msg.sender);
        }

        // Verify order is delivered (can only review completed orders)
        if (order.status != IMIDLOrder.OrderStatus.Delivered) {
            revert OrderNotDelivered(orderId);
        }

        // Check if already reviewed
        if (_orderReviewId[orderId] != 0) {
            revert AlreadyReviewed(orderId);
        }

        // Create review
        _reviewIds++;
        uint256 newReviewId = _reviewIds;

        Review memory review = Review({
            id: newReviewId,
            orderId: orderId,
            productId: productId,
            channelName: channelName.toLower(),
            reviewer: msg.sender,
            rating: rating,
            comment: comment,
            exists: true,
            createdAt: block.timestamp
        });

        // Store review
        reviews[newReviewId] = review;

        // Update mappings
        _orderReviewId[orderId] = newReviewId;
        _productReviews[productId].push(newReviewId);
        _channelReviews[channelName.toLower()].push(newReviewId);
        _reviewerReviews[msg.sender].push(newReviewId);

        emit ReviewCreated(
            newReviewId,
            orderId,
            productId,
            channelName.toLower(),
            msg.sender,
            rating
        );

        return newReviewId;
    }

    /**
     * @dev Update an existing review
     * @param reviewId The review ID
     * @param rating New rating (1-5)
     * @param comment New comment
     */
    function updateReview(
        uint256 reviewId,
        uint8 rating,
        string calldata comment
    ) external override onlyReviewer(reviewId) reviewExists(reviewId) {
        if (rating < 1 || rating > 5) {
            revert InvalidRating(rating);
        }

        Review storage review = reviews[reviewId];
        review.rating = rating;
        review.comment = comment;

        emit ReviewUpdated(reviewId, msg.sender, rating, comment);
    }

    /**
     * @dev Delete a review (soft delete)
     * @param reviewId The review ID
     */
    function deleteReview(uint256 reviewId)
        external
        override
        onlyReviewer(reviewId)
        reviewExists(reviewId)
    {
        Review storage review = reviews[reviewId];
        review.exists = false;

        emit ReviewDeleted(reviewId, msg.sender);
    }

    /**
     * @dev Get review by ID
     * @param reviewId The review ID
     * @return Review struct
     */
    function getReview(uint256 reviewId)
        external
        view
        override
        reviewExists(reviewId)
        returns (Review memory)
    {
        return reviews[reviewId];
    }

    /**
     * @dev Get all reviews for a product
     * @param productId The product ID
     * @return Array of Review structs
     */
    function getReviewsByProduct(uint256 productId)
        external
        view
        override
        returns (Review[] memory)
    {
        uint256[] storage reviewIds = _productReviews[productId];
        return _getReviewsFromIds(reviewIds);
    }

    /**
     * @dev Get all reviews for a channel
     * @param channelName The channel name
     * @return Array of Review structs
     */
    function getReviewsByChannel(string calldata channelName)
        external
        view
        override
        returns (Review[] memory)
    {
        string memory lowerChannel = channelName.toLower();
        uint256[] storage reviewIds = _channelReviews[lowerChannel];
        return _getReviewsFromIds(reviewIds);
    }

    /**
     * @dev Get all reviews by a reviewer
     * @param reviewer The reviewer's address
     * @return Array of Review structs
     */
    function getReviewsByReviewer(address reviewer)
        external
        view
        override
        returns (Review[] memory)
    {
        uint256[] storage reviewIds = _reviewerReviews[reviewer];
        return _getReviewsFromIds(reviewIds);
    }

    /**
     * @dev Check if a user has reviewed an order
     * @param reviewer The reviewer's address
     * @param orderId The order ID
     * @return True if reviewed
     */
    function hasReviewed(address reviewer, uint256 orderId)
        external
        view
        override
        returns (bool)
    {
        uint256 reviewId = _orderReviewId[orderId];
        return reviewId > 0 && reviews[reviewId].reviewer == reviewer && reviews[reviewId].exists;
    }

    /**
     * @dev Get average rating for a channel
     * @param channelName The channel name
     * @return (averageRating, reviewCount)
     */
    function getAverageRating(string calldata channelName)
        external
        view
        override
        returns (uint256, uint256)
    {
        string memory lowerChannel = channelName.toLower();
        uint256[] storage reviewIds = _channelReviews[lowerChannel];

        if (reviewIds.length == 0) {
            return (0, 0);
        }

        uint256 totalRating = 0;
        uint256 validReviews = 0;

        for (uint256 i = 0; i < reviewIds.length; i++) {
            Review memory review = reviews[reviewIds[i]];
            if (review.exists) {
                totalRating += review.rating;
                validReviews++;
            }
        }

        if (validReviews == 0) {
            return (0, 0);
        }

        return (totalRating / validReviews, validReviews);
    }

    /**
     * @dev Get total review count
     * @return Total number of reviews
     */
    function getReviewCount() external view override returns (uint256) {
        return _reviewIds;
    }

    // Internal functions

    function _getReviewsFromIds(uint256[] storage reviewIds)
        internal
        view
        returns (Review[] memory)
    {
        // First pass: count valid reviews
        uint256 validCount = 0;
        for (uint256 i = 0; i < reviewIds.length; i++) {
            if (reviews[reviewIds[i]].exists) {
                validCount++;
            }
        }

        // Second pass: populate array
        Review[] memory result = new Review[](validCount);
        uint256 index = 0;
        for (uint256 i = 0; i < reviewIds.length; i++) {
            Review memory review = reviews[reviewIds[i]];
            if (review.exists) {
                result[index] = review;
                index++;
            }
        }

        return result;
    }
}
