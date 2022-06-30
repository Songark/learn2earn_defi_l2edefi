/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CodifaiPool.sol";

contract CodifaiPoolFactory {
    
    function createCodifaiPool(address creator) 
    external returns (address) {
        return address(new CodifaiPool(msg.sender, creator));
    }
}