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

/// @notice Emitted when invalid msg.sender will try to remove pool
error CodifaiEngine__NotRequestedToRemove(address poolAddress);

contract CodifaiEngine is ICodifaiEngine, Ownable {
    using SafeMath for uint256 ;
    
    CodifaiPoolFactory private immutable __factory;

    address private _treasury;

    mapping(address => address) private _pools;

    mapping(address => address) private _requests;

    modifier onlyPoolOwner(address pool) {
        if (_pools[msg.sender] != pool)
            revert CodifaiEngine__NotPermissionForRemove({ownerAddress: msg.sender});
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

        address newPool = __factory.createCodifaiPool(msg.sender, tokens, amounts);
        _pools[msg.sender] = newPool;

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).transferFrom(msg.sender, _treasury, amounts[i].mul(20).div(100));
            IERC20(tokens[i]).transferFrom(msg.sender, newPool, amounts[i].mul(80).div(100));
        }

        emit CodifaiPoolCreated(newPool);
    }

    function requestRemoveCodifaiPool(address pool) external override onlyPoolOwner(pool) {
        _requests[pool] = msg.sender;
        emit CodifaiPoolRemoveSubmitted(pool);
    }

    function confirmRemoveCodifaiPool(address pool) external override onlyOwner {
        if (_requests[pool] == address(0))
            revert CodifaiEngine__NotRequestedToRemove({poolAddress: pool});

        ICodifaiPool(pool).withdraw();
        emit CodifaiPoolWithdrawed(pool, _requests[pool]);
    }

    function getCodifaiPool() external override view returns (address) {
        return _pools[msg.sender];
    }

    function getCodifaiPoolTokens(address pool) external override view returns (address[] memory) {
        return ICodifaiPool(pool).getPoolTokens();
    }

    function getCodifaiPoolBalance(address pool, address token) external override view returns (uint256) {
        return ICodifaiPool(pool).getPoolTokenBalance(token);
    }
}