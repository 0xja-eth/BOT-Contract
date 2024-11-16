// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./lib/@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./lib/@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address _owner, address _spender) external view returns (uint256);
  function approve(address _spender, uint _value) external returns (bool success);
}

enum TripStatus { Pending, Completed, Cancelled }

struct Trip {
  address initiator; // Trip initiator
  uint256 value; // Payment value

  uint256 startTime; // Trip start time
  uint256 estEndTime; // Trip estimated end time
  uint256 actEndTime; // Trip actual end time

  TripStatus status;
}

contract BOTPlatform is ReentrancyGuard, Ownable {

  address public estimator;
  address public verifier;

  uint256 constant public FEE_FACTOR = 10000;

  struct Tier {
    uint256 min;
    uint256 max;
    uint256 feeBps;
  }

  Tier[] public tiers;

  mapping(bytes => Trip) public trips; // Trip ID -> Trip

  mapping(address => bytes) public currentTrips; // User -> Trip ID
  mapping(string => address) public emails; // Email -> Address

  modifier onlyEstimator() {
    require(msg.sender == estimator, "Unauthorized");
    _;
  }
  modifier onlyVerifier() {
    require(msg.sender == verifier, "Unauthorized");
    _;
  }

  constructor() Ownable(msg.sender) {
    changeTier(0, Tier({ min: 0, max: 10, feeBps: 1000 }));
    changeTier(1, Tier({ min: 10, max: 20, fee: 2000 }));
    changeTier(2, Tier({ min: 20, max: 999, fee: 3000 }));
  }

  function changeTier(uint256 _index, Tier memory _tier) public onlyOwner {
    require(_index <= tiers.length, "Invalid index");

    if (_index == tiers.length) {
      tiers.push(_tier);
    } else {
      tiers[_index] = _tier;
    }
  }

  function changeEstimator(address _estimator) public onlyOwner {
    estimator = _estimator;
  }
  function changeVerifier(address _verifier) public onlyOwner {
    verifier = _verifier;
  }

  function registerEmail(address _user, string memory _email) public onlyOwner {
    emails[_email] = _user;
  }

  function startTrip(
    bytes memory _tripId, uint256 _startTime
  ) public payable nonReentrant {
    require(trips[_tripId].initiator == address(0), "Trip already started");
    require(msg.value > 0, "Invalid value");

    trips[_tripId] = Trip({
      initiator: msg.sender,
      value: msg.value,
      startTime: _startTime,
      estEndTime: 0,
      actEndTime: 0,
      status: TripStatus.Pending
    });

    currentTrips[msg.sender] = _tripId;
  }

  function estimateTrip(bytes memory _tripId, uint256 _estEndTime) public onlyEstimator {
    require(trips[_tripId].status == TripStatus.Pending, "Trip already completed or cancelled");
    require(trips[_tripId].estEndTime == 0, "Estimated end time already set");

    require(_estEndTime > trips[_tripId].startTime, "Invalid estimated end time");
    require(_estEndTime > block.timestamp, "Invalid estimated end time");

    trips[_tripId].estEndTime = _estEndTime;
  }

  function completeTrip(bytes memory _tripId) external onlyVerifier {

  }
}
