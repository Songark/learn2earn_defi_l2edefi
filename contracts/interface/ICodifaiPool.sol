/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiPool {
    
    function getPoolInformation() external view returns (address, uint256);
}