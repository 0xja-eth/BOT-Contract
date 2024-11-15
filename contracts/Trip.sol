// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./lib/@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address _owner, address _spender) external view returns (uint256);
  function approve(address _spender, uint _value) external returns (bool success);
}

enum TripStatus { Pending, Completed, Cancelled }

contract BOTPlatform is ReentrancyGuard {

  struct Trip {
    address initiator; // Trip initiator
    uint256 value; // Payment value

    uint256 startTime; // Trip start time
    uint256 estEndTime; // Trip estimated end time
    uint256 actEndTime; // Trip actual end time

    TripStatus status;
  }

  mapping(bytes => Trip) public trips; // Trip records -> IPFS



  function startTrip(
    bytes memory _tripId, uint256 _startTime, uint256 _estEndTime
  ) public payable nonReentrant {
    require(trips[_tripId].initiator == address(0), "Trip already started");
    require(msg.value > 0, "Invalid value");

    trips[_tripId] = Trip({
      initiator: msg.sender,
      value: msg.value,
      startTime: _startTime,
      estEndTime: _estEndTime,
      actEndTime: 0,
      status: TripStatus.Pending
    });
  }

}
