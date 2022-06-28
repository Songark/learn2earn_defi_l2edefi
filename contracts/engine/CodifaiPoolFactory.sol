/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CodifaiPool.sol";

contract CodifaiPoolFactory {
    
    function createCodifaiPool(address creator, address[] calldata tokens, uint256[] calldata amounts) 
    external returns (address) {
        return address(new CodifaiPool(msg.sender, creator, tokens, amounts));
    }
}