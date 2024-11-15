// Sources flattened with hardhat v2.22.15 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File contracts/lib/@openzeppelin/contracts/utils/ReentrancyGuard.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/LazyBet.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address _owner, address _spender) external view returns (uint256);
  function approve(address _spender, uint _value) external returns (bool success);
}

contract LazyBet is ReentrancyGuard {

  address public initiator; // Bet initiator
  address public judge; // Bet judge

  address public token; // Bet token
  uint public minValue; // Bet min value

  string public message; // Bet message
  uint public endTime; // Bet end time

  enum BetState { None, Open, Closed, Cancelled }

  struct Bet {
    uint value;
    uint8 bet; // 0: not bet, 1: bet true, 2: bet false
  }

  BetState public state; // Bet state

  address[] public participants; // Bet participants
  mapping(address => Bet) public bets; // Bet records

  uint[2] public betValues; // Bet values

  uint8 result; // Bet result

  modifier onlyInitiator() {
    require(msg.sender == initiator, "Only the initiator can perform this action");
    _;
  }

  modifier onlyJudge() {
    require(msg.sender == judge, "Only the judge can perform this action");
    _;
  }

  event BetOpened(address indexed initiator, address token, uint minValue, string message, uint endTime, address judge);
  event BetCancelled(address indexed initiator);
  event BetPlaced(address indexed participant, uint value, uint8 bet);
  event BetResultSet(uint8 result, address indexed judge);
  event BetClaimed(address indexed participant, uint value);

  constructor() { }

  function open(
    address _initiator,
    address _token,
    uint _minValue,
    string memory _message,
    uint _endTime,
    address _judge
  ) public {
    require(state == BetState.None, "The bet is not open");

    initiator = _initiator;
    token = _token;
    minValue = _minValue;
    message = _message;
    endTime = _endTime;
    judge = _judge;

    state = BetState.Open;

    emit BetOpened(initiator, token, minValue, message, endTime, judge);
  }

  function cancel() public onlyInitiator {
    require(state == BetState.Open, "The bet is not open");
    state = BetState.Cancelled;

    emit BetCancelled(initiator);
  }

  function bet(bool _result, uint _value) public payable nonReentrant {
    require(state == BetState.Open, "The bet is not open");
    require(block.timestamp < endTime, "The bet has ended");
    require(_value >= minValue, "The bet value must be greater than minimum value");
    require(bets[msg.sender].value == 0, "The participant has already bet");

    _pay(_value);

    participants.push(msg.sender);
    bets[msg.sender] = Bet(_value, _result ? 1 : 2);
    betValues[_result ? 0 : 1] += _value;

    emit BetPlaced(msg.sender, _value, _result ? 1 : 2);
  }

  function setResult(uint8 _result) public onlyJudge {
    require(state == BetState.Open, "The bet is not open");
    require(result == 0, "The result has already been set");
    require(_result == 1 || _result == 2, "Invalid result");

    result = _result;
    state = BetState.Closed;

    emit BetResultSet(result, judge);
  }

  function claim() public nonReentrant {
    require(state == BetState.Closed || state == BetState.Cancelled, "The bet is not closed or cancelled");

    uint _value = bets[msg.sender].value;
    require(_value > 0, "The participant has not bet");

    if (state == BetState.Cancelled) {
      _claim(_value); // Return the bet value
    } else {
      require(bets[msg.sender].bet == result, "The participant has not won");

      uint _total = betValues[0] + betValues[1];
      require(betValues[result - 1] > 0, "Division by zero in claim calculation");

      _claim(_total * _value / betValues[result - 1]); // Return the bet value
    }

    emit BetClaimed(msg.sender, _value);
  }

  function _pay(uint _value) internal {
    if (token == address(0)) {
      require(msg.value == _value, "Incorrect value");
    } else {
      IERC20(token).transferFrom(msg.sender, address(this), _value);
    }
  }

  function _claim(uint _value) internal {
    if (token == address(0)) {
      payable(msg.sender).transfer(_value);
    } else {
      IERC20(token).transfer(msg.sender, _value);
    }
  }
}
