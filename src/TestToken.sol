// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./KAP20.sol";

contract TestToken is KAP20 {
  constructor(
    string memory _name,
    string memory _symbol,
    string memory _projectName,
    uint8 _decimals,
    address _kyc,
    address _adminProjectRouter,
    address _committee,
    address _transferRouter,
    uint256 _acceptedKYCLevel
  )
  KAP20(
    _name,
    _symbol,
    _projectName,
    _decimals,
    _kyc,
    _adminProjectRouter,
    _committee,
    _transferRouter,
    _acceptedKYCLevel
  )
  {}

  function mint(address _to, uint256 _amount) external {
    _mint(_to, _amount);
  }
}
