/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interface/ICodifaiEngine.sol";
import "../interface/ICodifaiPool.sol";
import "./CodifaiPoolFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @notice Emitted when tokens'length isn't same with amounts' length
error CodifaiEngine__InvalidTokenParams(uint256 tokenLen, uint256 amountLen);

/// @notice Emitted when invalid msg.sender will try to remove pool
error CodifaiEngine__NotPermissionForRemove(address ownerAddress);

/// @notice Emitted when remove pool's request is invalid
error CodifaiEngine__NoRequestToRem(uint256 id);

/// @notice Emitted when invalid courseId entered
error CodifaiEngine__InvalidCourseId(uint256 id);

contract CodifaiEngine is ICodifaiEngine, Ownable {
    
    /// @param from sender's address
    /// @param completed 0: progress, 1: completed
    /// @param token token's address for withdraw
    /// @param value token's balance for withdraw
    struct request {
        address from;   
        uint128 completed;    
        address token;
        uint256 value;
    }

    using SafeMath for uint256 ;
    
    CodifaiPoolFactory private immutable __factory;

    address private _treasury;

    uint256 private _courseId;

    /// @dev mapping of courses, key is courseId, value is creator address
    mapping(uint256 => address) private _mapCourses;

    /// @dev mapping of pools for each creator, key is creator address, value is pool
    mapping(address => address) private _mapPools;

    /// @dev mapping of course remove organizer, key is pool address, value is requester address
    mapping(address => address) private _mapRemoveRequests;

    /// @dev mapping of course withdraw organizer, key is pool address, value is requester address
    mapping(address => request) private _mapWithdrawRequests;

    modifier onlyCourseOwner(uint256 courseId) {
        if (_mapCourses[courseId] != msg.sender)
            revert CodifaiEngine__InvalidCourseId({id: courseId});
        _;
    }

    modifier onlyValidId(uint256 courseId) {
        if (_mapPools[_mapCourses[courseId]] == address(0))
            revert CodifaiEngine__InvalidCourseId({id: courseId});
        _;
    }

    constructor(address treasury) {
        _treasury = treasury;
        __factory = new CodifaiPoolFactory();
    }

    function _getPool(uint256 courseId) internal view returns (address) {
        return _mapPools[_mapCourses[courseId]];
    }

    function createCourse(address[] calldata tokens, uint256[] calldata amounts) external override {
        if (tokens.length == 0 || tokens.length != amounts.length)
            revert CodifaiEngine__InvalidTokenParams({
                tokenLen: tokens.length, amountLen: amounts.length});

        uint256[] memory _amounts = amounts;
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).transferFrom(msg.sender, _treasury, amounts[i].mul(20).div(100));
            _amounts[i] = amounts[i].mul(80).div(100);
        }
        
        address pool = _mapPools[msg.sender];
        if (pool == address(0)) {
            pool = __factory.createCodifaiPool(msg.sender);
            _mapPools[msg.sender] = pool;
        }        

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).transferFrom(msg.sender, pool, _amounts[i]);
        }

        _courseId++;
        _mapCourses[_courseId] = msg.sender;
        ICodifaiPool(pool).depositTokens(_courseId, tokens, _amounts);
        
        emit CourseCreated(_courseId);
    }

    function setRewardsToCourse(uint256 courseId, address[] calldata tokens, uint256[] calldata rewards)
    external override onlyCourseOwner(courseId) {
        ICodifaiPool(_getPool(courseId)).setPoolRewards(courseId, tokens, rewards);
    }

    function setRoaltyToCourse(uint256 courseId, uint256 fee, address[] calldata sponsors) 
    external override onlyCourseOwner(courseId) {
        ICodifaiPool(_getPool(courseId)).setRoaltyForAuther(courseId, fee, sponsors);
    }

    function requestRemoveCourse(uint256 courseId) external override 
    onlyCourseOwner(courseId) {
        _mapRemoveRequests[_getPool(courseId)] = msg.sender;
        emit RequestRemoveSubmitted(courseId);
    }

    function confirmRemoveCourse(uint256 courseId) external override 
    onlyValidId(courseId) 
    onlyOwner {
        if (_mapRemoveRequests[_getPool(courseId)] == address(0))
            revert CodifaiEngine__NoRequestToRem({id: courseId});

        ICodifaiPool(_getPool(courseId)).withdraw(courseId);
        emit CourseWithdrawed(courseId);
    }

    function depositToCourse(address[] calldata tokens, uint256[] calldata amounts) external override {

    }

    function requestWithdrawCourse() external override {

    }

    function confirmWithdrawCourse() external override {

    }

    function completeCourse(uint256 courseId, address user) external override 
    onlyCourseOwner(courseId) {
        ICodifaiPool(_getPool(courseId)).completeCourse(user, courseId);
        emit CompletedCourse(courseId, user);
    }

    function claimRewards(uint256 courseId, address to) external override 
    onlyValidId(courseId) {
        ICodifaiPool(_getPool(courseId)).claimRewards(msg.sender, to);
    }

    function getPool() external override view returns (address) {
        return _mapPools[msg.sender];
    }

    function getCourseRewardTokens(uint256 courseId) external override 
    onlyValidId(courseId) 
    view returns (address[] memory) {
        return ICodifaiPool(_getPool(courseId)).getPoolTokens();
    }
}