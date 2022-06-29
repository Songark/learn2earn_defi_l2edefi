/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiEngine {
    
    event CodifaiPoolCreated(address indexed codifaiPool);

    event CodifaiPoolRemoveSubmitted(address indexed codifaiPool);

    event CodifaiPoolWithdrawed(address indexed codifaiPool, address indexed orgCustomer);
    
    function createCodifaiPool(address[] calldata tokens, uint256[] calldata amounts) external;

    function requestRemoveCodifaiPool(address pool) external;

    function confirmRemoveCodifaiPool(address pool) external;

    function getCodifaiPool() external view returns (address);

    function getCodifaiPoolTokens(address pool) external view returns (address[] memory);

    function getCodifaiPoolBalance(address pool, address token) external view returns (uint256);
}