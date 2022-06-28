/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiEngine {
    
    event CodifaiPoolCreated(address indexed CodifaiPool);
    
    function createCodifaiPool(address[] calldata tokens, uint256[] calldata amounts) external;

    function removeCodifaiPool(address pool) external;

    function getCodifaiPool() external view returns (address);

    function getCodifaiPoolTokens(address pool) external view returns (address[] memory);

    function getCodifaiPoolBalance(address pool, address token) external view returns (uint256);
}