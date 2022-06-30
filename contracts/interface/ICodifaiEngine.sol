/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICodifaiEngine {
    
    event CourseCreated(uint256 courseId);

    event RequestRemoveSubmitted(uint256 courseId);

    event CourseWithdrawed(uint256 courseId);

    event CompletedCourse(uint256 courseId, address user);
    
    function createCourse(address[] calldata tokens, uint256[] calldata amounts) external;

    function setRewardsToCourse(uint256 courseId, address[] calldata tokens, uint256[] calldata rewards) external;

    function setRoaltyToCourse(uint256 courseId, uint256 fee, address[] calldata sponsors) external;
    
    function requestRemoveCourse(uint256 courseId) external;

    function confirmRemoveCourse(uint256 courseId) external;

    function depositToCourse(address[] calldata tokens, uint256[] calldata amounts) external;

    function requestWithdrawCourse() external;

    function confirmWithdrawCourse() external;

    function completeCourse(uint256 courseId, address user) external;

    function claimRewards(uint256 courseId, address to) external;
 
    function getPool() external view returns (address);

    function getCourseRewardTokens(uint256 courseId) external view returns (address[] memory);
}