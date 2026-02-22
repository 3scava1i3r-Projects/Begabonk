// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMIDLResolver is IERC165 {
    // Events
    event AddrChanged(bytes32 indexed node, address a);
    event AddressChanged(bytes32 indexed node, uint256 coinType, bytes newAddress);
    event NameChanged(bytes32 indexed node, string name);
    event TextChanged(
        bytes32 indexed node,
        string indexed keyIndex,
        string key,
        string value
    );
    event ContenthashChanged(bytes32 indexed node, bytes hash);

    // Address resolution
    function addr(bytes32 node) external view returns (address payable);
    function addr(bytes32 node, uint256 coinType) external view returns (bytes memory);

    // Name resolution (reverse)
    function name(bytes32 node) external view returns (string memory);

    // Text records
    function text(bytes32 node, string calldata key) external view returns (string memory);

    // Content hash
    function contenthash(bytes32 node) external view returns (bytes memory);

    // Setters
    function setAddr(bytes32 node, address a) external;
    function setAddr(bytes32 node, uint256 coinType, bytes calldata a) external;
    function setName(bytes32 node, string calldata name) external;
    function setText(bytes32 node, string calldata key, string calldata value) external;
    function setContenthash(bytes32 node, bytes calldata hash) external;
}
