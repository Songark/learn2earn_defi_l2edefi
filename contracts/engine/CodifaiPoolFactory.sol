/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CodifaiPool.sol";

contract CodifaiPoolFactory {
    
    function createCodifaiPool(address creator, address token, uint256 amount) external returns (address) {
        return address(new CodifaiPool(msg.sender, creator, token, amount));
    }
}