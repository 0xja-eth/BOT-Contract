// Sources flattened with hardhat v2.22.15 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File src/KAP20.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.0;

interface IAdminProjectRouter {
  function isSuperAdmin(address _addr, string calldata _project) external view returns (bool);

  function isAdmin(address _addr, string calldata _project) external view returns (bool);
}

abstract contract Authorization {
  IAdminProjectRouter public adminProjectRouter;
  string public PROJECT; // Fill the project name

  event AdminProjectRouterSet(address indexed oldAdmin, address indexed newAdmin, address indexed caller);

  modifier onlySuperAdmin() {
    require(adminProjectRouter.isSuperAdmin(msg.sender, PROJECT), "Authorization: restricted only super admin");
    _;
  }

  modifier onlyAdmin() {
    require(adminProjectRouter.isAdmin(msg.sender, PROJECT), "Authorization: restricted only admin");
    _;
  }

  modifier onlySuperAdminOrAdmin() {
    require(
      adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) || adminProjectRouter.isAdmin(msg.sender, PROJECT),
      "Authorization: restricted only super admin or admin"
    );
    _;
  }

  function setAdminProjectRouter(address _adminProjectRouter) public virtual onlySuperAdmin {
    require(_adminProjectRouter != address(0), "Authorization: new admin project router is the zero address");
    emit AdminProjectRouterSet(address(adminProjectRouter), _adminProjectRouter, msg.sender);
    adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
  }
}

pragma solidity >=0.6.0 <0.9.0;

interface IKYCBitkubChain {
  function kycsLevel(address _addr) external view returns (uint256);
}

pragma solidity ^0.8.0;

abstract contract KYCHandler {
  IKYCBitkubChain public kyc;

  uint256 public acceptedKYCLevel;
  bool public isActivatedOnlyKYCAddress;

  function _activateOnlyKYCAddress() internal virtual {
    isActivatedOnlyKYCAddress = true;
  }

  function _setKYC(address _kyc) internal virtual {
    kyc = IKYCBitkubChain(_kyc);
  }

  function _setAcceptedKYCLevel(uint256 _kycLevel) internal virtual {
    acceptedKYCLevel = _kycLevel;
  }
}

pragma solidity ^0.8.0;

abstract contract Committee {
  address public committee;

  event CommitteeSet(address indexed oldCommittee, address indexed newCommittee, address indexed caller);

  modifier onlyCommittee() {
    require(msg.sender == committee, "Committee: restricted only committee");
    _;
  }

  function setCommittee(address _committee) public virtual onlyCommittee {
    emit CommitteeSet(committee, _committee, msg.sender);
    committee = _committee;
  }
}

pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _transferOwnership(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

pragma solidity ^0.8.0;

abstract contract AccessController is Authorization, KYCHandler, Committee {
  address public transferRouter;

  event TransferRouterSet(
    address indexed oldTransferRouter,
    address indexed newTransferRouter,
    address indexed caller
  );

  modifier onlySuperAdminOrTransferRouter() {
    require(
      adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) || msg.sender == transferRouter,
      "AccessController: restricted only super admin or transfer router"
    );
    _;
  }

  modifier onlySuperAdminOrCommittee() {
    require(
      adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) || msg.sender == committee,
      "AccessController: restricted only super admin or committee"
    );
    _;
  }

  function activateOnlyKYCAddress() external onlyCommittee {
    _activateOnlyKYCAddress();
  }

  function setKYC(address _kyc) external onlyCommittee {
    _setKYC(_kyc);
  }

  function setAcceptedKYCLevel(uint256 _kycLevel) external onlyCommittee {
    _setAcceptedKYCLevel(_kycLevel);
  }

  function setTransferRouter(address _transferRouter) external onlyCommittee {
    emit TransferRouterSet(transferRouter, _transferRouter, msg.sender);
    transferRouter = _transferRouter;
  }

  function setAdminProjectRouter(address _adminProjectRouter) public override onlyCommittee {
    require(_adminProjectRouter != address(0), "Authorization: new admin project router is the zero address");
    emit AdminProjectRouterSet(address(adminProjectRouter), _adminProjectRouter, msg.sender);
    adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
  }
}

pragma solidity ^0.8.0;

abstract contract Pausable {
  event Paused(address account);

  event Unpaused(address account);

  bool public paused;

  constructor() {
    paused = false;
  }

  modifier whenNotPaused() {
    require(!paused, "Pausable: paused");
    _;
  }

  modifier whenPaused() {
    require(paused, "Pausable: not paused");
    _;
  }

  function _pause() internal virtual whenNotPaused {
    paused = true;
    emit Paused(msg.sender);
  }

  function _unpause() internal virtual whenPaused {
    paused = false;
    emit Unpaused(msg.sender);
  }
}

pragma solidity >=0.6.0 <0.9.0;

interface IKAP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function adminApprove(
    address owner,
    address spender,
    uint256 amount
  ) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function adminTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.6.0 <0.9.0;

interface IKToken {
  function internalTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function externalTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}

pragma solidity ^0.8.0;

contract KAP20 is IKAP20, IKToken, Pausable, AccessController {
  mapping(address => uint256) _balances;

  mapping(address => mapping(address => uint256)) internal _allowances;

  uint256 public override totalSupply;

  string public override name;
  string public override symbol;
  uint8 public override decimals;

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
  ) {
    name = _name;
    symbol = _symbol;
    PROJECT = _projectName;
    decimals = _decimals;
    kyc = IKYCBitkubChain(_kyc);
    adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
    committee = _committee;
    transferRouter = _transferRouter;
    acceptedKYCLevel = _acceptedKYCLevel;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override whenNotPaused returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function adminApprove(
    address owner,
    address spender,
    uint256 amount
  ) public virtual override whenNotPaused onlySuperAdminOrAdmin returns (bool) {
    require(
      kyc.kycsLevel(owner) >= acceptedKYCLevel && kyc.kycsLevel(spender) >= acceptedKYCLevel,
      "KAP20: owner or spender address is not a KYC user"
    );

    _approve(owner, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override whenNotPaused returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(currentAllowance >= amount, "KAP20: transfer amount exceeds allowance");
  unchecked {
    _approve(sender, msg.sender, currentAllowance - amount);
  }

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    require(currentAllowance >= subtractedValue, "KAP20: decreased allowance below zero");
  unchecked {
    _approve(msg.sender, spender, currentAllowance - subtractedValue);
  }

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "KAP20: transfer from the zero address");
    require(recipient != address(0), "KAP20: transfer to the zero address");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "KAP20: transfer amount exceeds balance");
  unchecked {
    _balances[sender] = senderBalance - amount;
  }
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "KAP20: mint to the zero address");

    totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "KAP20: burn from the zero address");

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "KAP20: burn amount exceeds balance");
  unchecked {
    _balances[account] = accountBalance - amount;
  }
    totalSupply -= amount;

    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "KAP20: approve from the zero address");
    require(spender != address(0), "KAP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function adminTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override onlyCommittee returns (bool) {
    if (isActivatedOnlyKYCAddress) {
      require(kyc.kycsLevel(sender) > 0 && kyc.kycsLevel(recipient) > 0, "KAP721: only internal purpose");
    }
    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "KAP20: transfer amount exceeds balance");
  unchecked {
    _balances[sender] = senderBalance - amount;
  }
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);

    return true;
  }

  function internalTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) external override whenNotPaused onlySuperAdminOrTransferRouter returns (bool) {
    require(
      kyc.kycsLevel(sender) >= acceptedKYCLevel && kyc.kycsLevel(recipient) >= acceptedKYCLevel,
      "KAP20: only internal purpose"
    );

    _transfer(sender, recipient, amount);
    return true;
  }

  function externalTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) external override whenNotPaused onlySuperAdminOrTransferRouter returns (bool) {
    require(kyc.kycsLevel(sender) >= acceptedKYCLevel, "KAP20: only internal purpose");

    _transfer(sender, recipient, amount);
    return true;
  }
}


// File src/lib/@openzeppelin/contracts/utils/Context.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity 0.8.19; // Modified

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like src.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File src/lib/@openzeppelin/contracts/access/Ownable.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity 0.8.19; // Modified

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File src/lib/@openzeppelin/contracts/utils/ReentrancyGuard.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity 0.8.19; // Modified

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


// File src/BOTPlatform.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.0;

//import "./lib/@openzeppelin/contracts/token/ERC20/IERC20.sol";


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

  uint256 constant public MIN_PAY_VALUE = 1;
  uint256 constant public MAX_PAY_VALUE = 30;

  uint256 constant public INVALID_THRESHOLD = 10 minutes;

  struct Tier {
    uint256 minDelay; // minute
    uint256 maxDelay; // minute
    uint256 rewardBps;
  }

  Tier[] public tiers;

  mapping(string => Trip) public trips; // Trip ID -> Trip

  mapping(address => string) public currentTrips; // User -> Trip ID
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
    string memory _tripId, uint256 _startTime, uint256 _value, address bitkubNext_
  ) external nonReentrant {
    uint256 minPayValue = MIN_PAY_VALUE * 10 ** IKAP20(token).decimals();
    uint256 maxPayValue = MAX_PAY_VALUE * 10 ** IKAP20(token).decimals();

    require(trips[_tripId].initiator == address(0), "Trip already started");
    require(_value >= minPayValue && _value <= maxPayValue, "Invalid value");

    IKAP20(token).transferFrom(msg.sender, address(this), _value);

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

  function estimateTrip(string memory _tripId, uint256 _estEndTime) public onlyEstimator {
    require(trips[_tripId].initiator != address(0), "Trip not existed");
    require(trips[_tripId].status == TripStatus.Pending, "Trip already completed or cancelled");
    require(trips[_tripId].estEndTime == 0, "Estimated end time already set");

    require(_estEndTime > trips[_tripId].startTime, "Invalid estimated end time");
    require(_estEndTime > block.timestamp, "Invalid estimated end time");

    trips[_tripId].estEndTime = _estEndTime;
  }

  function completeTrip(string memory _tripId, uint256 _actStartTime, uint256 _actEndTime) external onlyVerifier {
    require(trips[_tripId].initiator != address(0), "Trip not existed");
    require(trips[_tripId].status == TripStatus.Pending, "Trip already completed or cancelled");
    require(trips[_tripId].actStartTime == 0, "Actual start time already set");
    require(trips[_tripId].actEndTime == 0, "Actual end time already set");

    trips[_tripId].actStartTime = _actStartTime;
    trips[_tripId].actEndTime = _actEndTime;

    if ((_actStartTime > trips[_tripId].startTime && _actStartTime - trips[_tripId].startTime >= INVALID_THRESHOLD) ||
        (_actStartTime < trips[_tripId].startTime && trips[_tripId].startTime - _actStartTime >= INVALID_THRESHOLD)) {
      trips[_tripId].status = TripStatus.Cancelled; // Cancelled due to late start
      return;
    }

    uint256 actDuration = _actEndTime - _actStartTime;
    uint256 estDuration = trips[_tripId].estEndTime - trips[_tripId].startTime;

    if (actDuration <= estDuration) {
      trips[_tripId].status = TripStatus.Completed;
      return;
    }

    uint256 deltaDuration = actDuration - estDuration; // In seconds
    uint256 deltaDurationMinutes = deltaDuration / 1 minutes; // In minutes

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

  function claim(address bitkubNext_) public nonReentrant {
    require(claimable[msg.sender] > 0, "No claimable balance");

    claimable[msg.sender] = 0;

    IKAP20(token).transfer(msg.sender, claimable[msg.sender]);
  }

  function withdraw(address receiver) public onlyOwner {
    IKAP20(token).transfer(receiver, IKAP20(token).balanceOf(address(this)));
  }
}
