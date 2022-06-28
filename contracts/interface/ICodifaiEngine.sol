/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiEngine {
    
    event CodifaiPoolCreated(address indexed CodifaiPool);
    
    function createCodifaiPool(address token, uint256 amount) external;

    function getCodifaiPool() external view returns (address);

    function getCodifaiPoolInfo(address pool) external view returns (address, uint256);
}