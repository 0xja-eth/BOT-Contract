// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./lib/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
  constructor() ERC20("TestToken", "TT") {
    _mint(msg.sender, 1000000000 * 10 ** decimals());
  }

  function mint(address to, uint256 amount) public {
    _mint(to, amount);
  }
}

