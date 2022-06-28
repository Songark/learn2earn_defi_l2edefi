/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interface/ICodifaiPool.sol";

contract CodifaiPool is ICodifaiPool {

    address private _engine;

    address private _creator;

    address private _token;

    uint256 _amount;

    modifier onlyEngine() {
        require(msg.sender == _engine, "Only allowed from engine");
        _;
    }

    constructor(address engine, address creator, address token, uint256 amount) {
        _engine = engine;
        _creator = creator;
        _token = token;
        _amount = amount;
    }

    function getPoolInformation() external override onlyEngine view returns (address, uint256) {
        return (_token, _amount);
    }
}