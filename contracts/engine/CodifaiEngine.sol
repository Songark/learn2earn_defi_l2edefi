/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interface/ICodifaiEngine.sol";
import "../interface/ICodifaiPool.sol";
import "./CodifaiPoolFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @notice Emitted when tokens'length isn't same with amounts' length
error CodifaiEngine__InvalidTokensAndAmounts(uint256 tokenLen, uint256 amountLen);

/// @notice Emitted when invalid msg.sender will try to remove pool
error CodifaiEngine__NotPermissionForRemove(address ownerAddress);

/// @notice Emitted when remove pool's request is invalid
error CodifaiEngine__NotRequestedToRemove(uint256 index);

/// @notice Emitted when invalid poolIndex entered
error CodifaiEngine__InvalidPoolIndex(uint256 index);

contract CodifaiEngine is ICodifaiEngine, Ownable {
    using SafeMath for uint256 ;
    
    CodifaiPoolFactory private immutable __factory;

    address private _treasury;

    /// @dev array of all pools
    address[] private _allPools;

    /// @dev mapping of pools for each creator, key is creator address, value is pool address
    mapping(address => address) private _creatorPool;

    /// @dev mapping of pool withdrawl requester, key is pool address, value is requester address
    mapping(address => address) private _poolRequester;

    modifier onlyPoolOwner(uint256 poolIndex) {
        if (_allPools.length <= poolIndex)
            revert CodifaiEngine__InvalidPoolIndex({index: poolIndex});
        if (_creatorPool[msg.sender] != _allPools[poolIndex])
            revert CodifaiEngine__NotPermissionForRemove({ownerAddress: msg.sender});
        _;
    }

    modifier onlyValidIndex(uint256 poolIndex) {
        if (_allPools.length <= poolIndex)
            revert CodifaiEngine__InvalidPoolIndex({index: poolIndex});
        _;
    }

    constructor(address treasury) {
        _treasury = treasury;
        __factory = new CodifaiPoolFactory();
    }

    function createCodifaiPool(address[] calldata tokens, uint256[] calldata amounts) external override {
        if (tokens.length == 0 || tokens.length != amounts.length)
            revert CodifaiEngine__InvalidTokensAndAmounts({
                tokenLen: tokens.length, amountLen: amounts.length});
        uint256[] memory _amounts = amounts;
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).transferFrom(msg.sender, _treasury, amounts[i].mul(20).div(100));
            _amounts[i] = amounts[i].mul(80).div(100);
        }

        address newPool = __factory.createCodifaiPool(msg.sender, tokens, _amounts);
        _allPools.push(newPool);
        _creatorPool[msg.sender] = newPool;

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).transferFrom(msg.sender, newPool, _amounts[i]);
        }

        emit CodifaiPoolCreated(_allPools.length.sub(1));
    }

    function setCodifaiPoolRewards(uint256 poolIndex, uint256[] calldata rewards) external override
    onlyValidIndex(poolIndex) {
        ICodifaiPool(_allPools[poolIndex]).setPoolRewards(rewards);
    }


    function requestRemoveCodifaiPool(uint256 poolIndex) external override 
    onlyValidIndex(poolIndex) 
    onlyPoolOwner(poolIndex) {
        _poolRequester[_allPools[poolIndex]] = msg.sender;
        emit CodifaiPoolRemoveSubmitted(poolIndex);
    }

    function confirmRemoveCodifaiPool(uint256 poolIndex) external override 
    onlyValidIndex(poolIndex) 
    onlyOwner {
        if (_poolRequester[_allPools[poolIndex]] == address(0))
            revert CodifaiEngine__NotRequestedToRemove({index: poolIndex});

        ICodifaiPool(_allPools[poolIndex]).withdraw();
        emit CodifaiPoolWithdrawed(poolIndex);
    }

    function getCodifaiPool() external override view returns (address) {
        return _creatorPool[msg.sender];
    }

    function getCodifaiPoolTokens(uint256 poolIndex) external override 
    onlyValidIndex(poolIndex) 
    view returns (address[] memory) {
        return ICodifaiPool(_allPools[poolIndex]).getPoolTokens();
    }

    function getCodifaiPoolBalance(uint256 poolIndex, address token) external override 
    onlyValidIndex(poolIndex) 
    view returns (uint256) {
        return ICodifaiPool(_allPools[poolIndex]).getPoolTokenBalance(token);
    }

    function completeLearning(uint256 poolIndex) external override 
    onlyValidIndex(poolIndex) {
        ICodifaiPool(_allPools[poolIndex]).completeLearning(msg.sender);
        emit CodifaiCompletedCourse(poolIndex);
    }

    function claimRewards(uint256 poolIndex, address to) external override 
    onlyValidIndex(poolIndex) {
        ICodifaiPool(_allPools[poolIndex]).claimRewards(msg.sender, to);
    }
}