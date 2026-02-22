// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Base64 {
    bytes internal constant TABLE = bytes("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/");

    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);
        bytes memory result = new bytes(encodedLen);

        uint256 resultIndex;
        uint256 i;

        for (i = 0; i < len - 2; i += 3) {
            result[resultIndex++] = TABLE[uint256(uint8(data[i])) >> 2];
            result[resultIndex++] = TABLE[((uint256(uint8(data[i])) & 3) << 4) | (uint256(uint8(data[i + 1])) >> 4)];
            result[resultIndex++] = TABLE[((uint256(uint8(data[i + 1])) & 15) << 2) | (uint256(uint8(data[i + 2])) >> 6)];
            result[resultIndex++] = TABLE[uint256(uint8(data[i + 2])) & 63];
        }

        if (len % 3 == 2) {
            result[resultIndex++] = TABLE[uint256(uint8(data[i])) >> 2];
            result[resultIndex++] = TABLE[((uint256(uint8(data[i])) & 3) << 4) | (uint256(uint8(data[i + 1])) >> 4)];
            result[resultIndex++] = TABLE[(uint256(uint8(data[i + 1])) & 15) << 2];
            result[resultIndex] = bytes1("=");
        } else if (len % 3 == 1) {
            result[resultIndex++] = TABLE[uint256(uint8(data[i])) >> 2];
            result[resultIndex++] = TABLE[(uint256(uint8(data[i])) & 3) << 4];
            result[resultIndex++] = bytes1("=");
            result[resultIndex] = bytes1("=");
        }

        return string(result);
    }
}