/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interface/ICodifaiEngine.sol";
import "../interface/ICodifaiPool.sol";
import "./CodifaiPoolFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CodifaiEngine is ICodifaiEngine, Ownable {
    using SafeMath for uint256 ;
    
    CodifaiPoolFactory private immutable __factory;

    address private _treasury;

    mapping(address => address) private _pools;

    constructor(address treasury) {
        _treasury = treasury;
        __factory = new CodifaiPoolFactory();
    }

    function createCodifaiPool(address token, uint256 amount) external override {
        address newPool = __factory.createCodifaiPool(msg.sender, token, amount);
        _pools[msg.sender] = newPool;

        IERC20(token).transferFrom(msg.sender, _treasury, amount.mul(20).div(100));
        IERC20(token).transferFrom(msg.sender, newPool, amount.mul(80).div(100));

        emit CodifaiPoolCreated(newPool);
    }

    function getCodifaiPool() external override view returns (address) {
        return _pools[msg.sender];
    }

    function getCodifaiPoolInfo(address pool) external override view returns (address, uint256) {
        return ICodifaiPool(pool).getPoolInformation();
    }
}