//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestToken is ERC20 {
    constructor(string memory name_,string memory symbol_,uint256 _totalSupply) ERC20(name_, symbol_) {
        _mint(msg.sender, _totalSupply * 10 ** decimals());
    }
}
