/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiPool {
    
    function getPoolTokens() external view returns (address[] memory);

    function getPoolTokenBalance(address token) external view returns (uint256);
}