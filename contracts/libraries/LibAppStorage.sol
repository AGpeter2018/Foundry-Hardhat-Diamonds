// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct AppStorage {
    string name;
    string symbol;
    mapping(uint256 => address) owners;
    mapping(address => uint256) balances;
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping(address => bool)) operatorApprovals;
    uint256 totalSupply;
}

library LibAppStorage {
    // Utility functions to access AppStorage if needed from other libraries
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}
