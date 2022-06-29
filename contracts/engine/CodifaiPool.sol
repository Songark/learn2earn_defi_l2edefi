/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interface/ICodifaiPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CodifaiPool is ICodifaiPool {

    address private _engine;

    address private _creator;

    address[] private _tokens;

    mapping(address => uint256) private _amounts;

    modifier onlyEngine() {
        require(msg.sender == _engine, "Only allowed from engine");
        _;
    }

    constructor(address engine, address creator, address[] memory tokens, uint256[] memory amounts) {
        _engine = engine;
        _creator = creator;
        for (uint256 i = 0; i < tokens.length; i++) {
            _tokens.push(tokens[i]);
            _amounts[tokens[i]] = amounts[i];
        }
    }

    function getPoolTokens() external override onlyEngine view returns (address[] memory) {
        return _tokens;
    }

    function getPoolTokenBalance(address token) external override onlyEngine view returns (uint256)
    {
        return _amounts[token];
    }

    function withdraw() external override onlyEngine {
        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20(_tokens[i]).transfer(_creator, _amounts[_tokens[i]]);
            _amounts[_tokens[i]] = 0;
        }
    }
}