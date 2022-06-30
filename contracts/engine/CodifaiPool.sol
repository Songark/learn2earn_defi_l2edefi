/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interface/ICodifaiPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CodifaiPool is ICodifaiPool {

    address private _engine;

    address private _creator;

    address[] private _tokens;

    mapping(address => bool) _inserted;

    mapping(address => mapping(uint256 => uint256)) private _amounts;

    mapping(address => mapping(uint256 => uint256)) private _rewards;

    mapping(address => mapping(address => uint256)) private _balances;

    mapping(address => mapping(uint256 => bool)) private _completed;

    mapping(uint256 => address[]) _sponsors;

    mapping(uint256 => uint256) _sponsorFees;
    
    modifier onlyEngine() {
        require(msg.sender == _engine, "Only allowed from engine");
        _;
    }

    constructor(address engine, address creator) {
        _engine = engine;
        _creator = creator;
    }

    function depositTokens(uint256 courseId, address[] calldata tokens, uint256[] calldata amounts) 
    external override onlyEngine {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (!_inserted[tokens[i]])
                _tokens.push(tokens[i]);
            _inserted[tokens[i]] = true;
            _amounts[tokens[i]][courseId] = amounts[i];
        }
    }

    function setPoolRewards(uint256 courseId, address[] calldata tokens, uint256[] calldata rewards) 
    external override onlyEngine {
        require(rewards.length == tokens.length, "Invalid array length for rewards");
        for (uint256 i = 0; i < tokens.length; i++) {
            require(_inserted[tokens[i]], "Invalid token address");
            _rewards[tokens[i]][courseId] = rewards[i];
        }
    }

    function setRoaltyForAuther(uint256 courseId, uint256 fee, address[] calldata sponsors) 
    external override onlyEngine {
        require(fee <= 10, "Invalid roalyty fee");
        for (uint256 i = 0; i < sponsors.length; i++) {
            require(sponsors[i] != address(0), "Invalid sponsor addresses");
            _sponsors[courseId].push(sponsors[i]);
        }
        _sponsorFees[courseId] = fee;
    }

    function getPoolTokens() external override onlyEngine view returns (address[] memory) {
        return _tokens;
    }

    function withdraw(uint256 courseId) external override onlyEngine {
        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20(_tokens[i]).transfer(_creator, _amounts[_tokens[i]][courseId]);
            _amounts[_tokens[i]][courseId] = 0;
        }
    }

    function completeCourse(address user, uint256 courseId) external override onlyEngine {
        require(!_completed[user][courseId], "Already completed this course");

        _completed[user][courseId] = true;
        for (uint256 i = 0; i < _tokens.length; i++) {
            uint256 rewards = _rewards[_tokens[i]][courseId];
            uint256 sponsorfee = (rewards * _sponsorFees[courseId]) / 100;

            require(_amounts[_tokens[i]][courseId] >= rewards, "Insufficient balance for rewards");

            _amounts[_tokens[i]][courseId] -= rewards;
            _balances[user][_tokens[i]] += (rewards - sponsorfee);

            for (uint256 j = 0; j < _sponsors[courseId].length; j++) {
                _balances[_sponsors[courseId][j]][_tokens[i]] += (sponsorfee / _sponsors[courseId].length);
            }
        }        
    }

    function claimRewards(address user, address to) external override onlyEngine {
        require(to!= address(0), "Invalid address to for rewards");

        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_balances[user][_tokens[i]] > 0) {
                IERC20(_tokens[i]).transfer(to, _balances[user][_tokens[i]]);
            }            
        }
    }
}