/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interface/ICodifaiPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CodifaiPool is ICodifaiPool {

    address private _engine;

    address private _creator;

    address[] private _tokens;

    mapping(address => uint256) private _amounts;

    mapping(address => uint256) private _rewards;

    mapping(address => mapping(address => uint256)) private _balances;

    mapping(address => bool) private _completed;

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

    function setPoolRewards(uint256[] calldata rewards) external override {
        require(rewards.length == _tokens.length, "Invalid array length for rewards");
        for (uint256 i = 0; i < rewards.length; i++) {
            _rewards[_tokens[i]] = rewards[i];
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

    function completeLearning(address user) external override onlyEngine {
        require(!_completed[user], "Already completed this course");
        
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_balances[user][_tokens[i]] == 0) {
                require(_amounts[_tokens[i]] >= _rewards[_tokens[i]], "Insufficient balance for rewards");

                _balances[user][_tokens[i]] = _rewards[_tokens[i]];
                _amounts[_tokens[i]] -= _rewards[_tokens[i]];
            }            
        }        
    }

    function claimRewards(address user, address to) external override onlyEngine {
        require(to!= address(0), "Invalid address to for rewards");

        _completed[user] = true;
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_balances[user][_tokens[i]] > 0) {
                IERC20(_tokens[i]).transfer(to, _balances[user][_tokens[i]]);
            }            
        }
    }
}