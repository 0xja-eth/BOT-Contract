// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./lib/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./lib/@openzeppelin/contracts/access/Ownable.sol";

enum TripStatus { Pending, Completed, Cancelled }

struct Trip {
  address initiator; // Trip initiator
  uint256 value; // Payment value

  uint256 startTime; // Trip start time
  uint256 estEndTime; // Trip estimated end time

  uint256 actStartTime; // Trip actual start time
  uint256 actEndTime; // Trip actual end time

  TripStatus status;
}

contract BOTPlatform is ReentrancyGuard, Ownable {

  address public token; // USDC

  address public estimator;
  address public verifier;

  uint256 constant public FEE_FACTOR = 10000;
  uint256 constant public MAX_DELAY = 99999;

  uint256 constant public MIN_PAY_VALUE = 1 ether;
  uint256 constant public MAX_PAY_VALUE = 30 ether;

  struct Tier {
    uint256 minDelay; // minute
    uint256 maxDelay; // minute
    uint256 rewardBps;
  }

  Tier[] public tiers;

  mapping(bytes => Trip) public trips; // Trip ID -> Trip

  mapping(address => bytes) public currentTrips; // User -> Trip ID
  mapping(string => address) public emails; // Email -> Address

  mapping(address => uint256) public claimable; // User -> Claimable Balance

  modifier onlyEstimator() {
    require(msg.sender == estimator, "Unauthorized");
    _;
  }
  modifier onlyVerifier() {
    require(msg.sender == verifier, "Unauthorized");
    _;
  }

  constructor() Ownable(msg.sender) {
    changeTier(0, Tier(0, 10, 1000));
    changeTier(1, Tier(10, 30, 3000));
    changeTier(2, Tier(30, MAX_DELAY, 10000));
  }

  function changeTier(uint256 _index, Tier memory _tier) public onlyOwner {
    require(_index <= tiers.length, "Invalid index");

    if (_index == tiers.length) {
      tiers.push(_tier);
    } else {
      tiers[_index] = _tier;
    }
  }

  function changeToken(address _token) public onlyOwner {
    token = _token;
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
    bytes memory _tripId, uint256 _startTime, uint256 _value
  ) public nonReentrant {
    require(trips[_tripId].initiator == address(0), "Trip already started");
    require(_value >= MIN_PAY_VALUE && _value <= MAX_PAY_VALUE, "Invalid value");

    IERC20(token).transferFrom(msg.sender, address(this), _value);

    trips[_tripId] = Trip({
      initiator: msg.sender,
      value: _value,
      startTime: _startTime,
      estEndTime: 0,
      actStartTime: 0,
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

  function completeTrip(bytes memory _tripId, uint256 _actStartTime, uint256 _actEndTime) external onlyVerifier {
    require(trips[_tripId].status == TripStatus.Pending, "Trip already completed or cancelled");
    require(trips[_tripId].actStartTime == 0, "Actual start time already set");
    require(trips[_tripId].actEndTime == 0, "Actual end time already set");

    trips[_tripId].actStartTime = _actStartTime;
    trips[_tripId].actEndTime = _actEndTime;

    uint256 actDuration = _actEndTime - _actStartTime;
    uint256 estDuration = trips[_tripId].estEndTime - trips[_tripId].startTime;

    if (actDuration <= estDuration) {
      trips[_tripId].status = TripStatus.Cancelled;
      return;
    }

    uint256 deltaDuration = actDuration - estDuration; // In seconds
    uint256 deltaDurationMinutes = deltaDuration / 60; // In minutes

    require(deltaDurationMinutes <= MAX_DELAY, "Invalid delay");

    // Find tier
    for (uint256 i = 0; i < tiers.length; i++) {
      if (deltaDurationMinutes >= tiers[i].minDelay && deltaDurationMinutes < tiers[i].maxDelay) {
        uint256 fee = trips[_tripId].value * tiers[i].rewardBps / FEE_FACTOR;
        uint256 amount = trips[_tripId].value + fee;

        claimable[trips[_tripId].initiator] += amount;
        break;
      }
    }

    trips[_tripId].status = TripStatus.Completed;
  }

  function claim() public nonReentrant {
    require(claimable[msg.sender] > 0, "No claimable balance");

    claimable[msg.sender] = 0;

    IERC20(token).transfer(msg.sender, claimable[msg.sender]);
  }

  function withdraw(address receiver) public onlyOwner {
    IERC20(token).transfer(receiver, IERC20(token).balanceOf(address(this)));
  }
}
