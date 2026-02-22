// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IMIDLReview
 * @dev Interface for the MIDL Review - verified reviews for purchases
 */
interface IMIDLReview {
    // Review structure
    struct Review {
        uint256 id;
        uint256 orderId;
        uint256 productId;
        string channelName;
        address reviewer;
        uint8 rating; // 1-5
        string comment;
        bool exists;
        uint256 createdAt;
    }

    // Events
    event ReviewCreated(
        uint256 indexed reviewId,
        uint256 indexed orderId,
        uint256 indexed productId,
        string channelName,
        address reviewer,
        uint8 rating
    );
    event ReviewUpdated(
        uint256 indexed reviewId,
        address indexed reviewer,
        uint8 rating,
        string comment
    );
    event ReviewDeleted(
        uint256 indexed reviewId,
        address indexed deleter
    );

    // Functions
    function createReview(
        uint256 orderId,
        uint256 productId,
        string calldata channelName,
        uint8 rating,
        string calldata comment
    ) external returns (uint256);

    function updateReview(
        uint256 reviewId,
        uint8 rating,
        string calldata comment
    ) external;

    function deleteReview(uint256 reviewId) external;

    function getReview(uint256 reviewId) external view returns (Review memory);

    function getReviewsByProduct(uint256 productId)
        external
        view
        returns (Review[] memory);

    function getReviewsByChannel(string calldata channelName)
        external
        view
        returns (Review[] memory);

    function getReviewsByReviewer(address reviewer)
        external
        view
        returns (Review[] memory);

    function hasReviewed(address reviewer, uint256 orderId)
        external
        view
        returns (bool);

    function getAverageRating(string calldata channelName)
        external
        view
        returns (uint256, uint256);

    function getReviewCount() external view returns (uint256);
}
