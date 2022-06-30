/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiPool {    

    function setPoolRewards(uint256[] calldata rewards) external;

    function getPoolTokens() external view returns (address[] memory);

    function getPoolTokenBalance(address token) external view returns (uint256);

    function withdraw() external;

    function completeLearning(address user) external;

    function claimRewards(address user, address to) external;
    
}