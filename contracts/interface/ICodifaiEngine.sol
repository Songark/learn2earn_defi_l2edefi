/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiEngine {
    
    event CodifaiPoolCreated(uint256 poolIndex);

    event CodifaiPoolRemoveSubmitted(uint256 poolIndex);

    event CodifaiPoolWithdrawed(uint256 poolIndex);

    event CodifaiCompletedCourse(uint256 poolIndex);
    
    function createCodifaiPool(address[] calldata tokens, uint256[] calldata amounts) external;

    function setCodifaiPoolRewards(uint256 poolIndex, uint256[] calldata rewards) external;
    
    function requestRemoveCodifaiPool(uint256 poolIndex) external;

    function confirmRemoveCodifaiPool(uint256 poolIndex) external;

    function getCodifaiPool() external view returns (address);

    function getCodifaiPoolTokens(uint256 poolIndex) external view returns (address[] memory);

    function getCodifaiPoolBalance(uint256 poolIndex, address token) external view returns (uint256);

    function completeLearning(uint256 poolIndex) external;

    function claimRewards(uint256 poolIndex, address to) external;
}