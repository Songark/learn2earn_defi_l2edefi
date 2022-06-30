/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiPool {  

    function depositTokens(uint256 courseId, address[] calldata tokens, uint256[] calldata amounts) external;

    function setPoolRewards(uint256 courseId, address[] calldata tokens, uint256[] calldata rewards) external;

    function setRoaltyForAuther(uint256 courseId, uint256 fee, address[] calldata sponsors) external;

    function getPoolTokens() external view returns (address[] memory);

    function withdraw(uint256 courseId) external;

    function completeCourse(address user, uint256 courseId) external;

    function claimRewards(address user, address to) external;
    
}