pragma solidity ^0.5.1;

import "./MeditToken.sol";
import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


/**
 * humantiv role
 * info
 * transfer
 */
contract HumantivMeditPool is Ownable, Pausable {
  using Roles for Roles.Role;
  using SafeMath for uint256;

  Roles.Role private humantivRole_;
  MeditToken private token_;
  uint256 private releaseTimeLock_;
  uint256 public releaseAmount_;
  uint256 public releaseRequestTime_;  

  constructor (MeditToken _token, uint256 _timeLock) public {
    token_ = _token;
    releaseTimeLock_ = _timeLock;
    humantivRole_.add(msg.sender);
    emit HumantivRoleAdded(address(this), msg.sender);
  }

  modifier onlyHumantivRole() {
    require(humantivRole_.has(msg.sender));
    _;
  }

  function totalMedit() public view returns (uint256) {
    return token_.totalSupply();
  }

  function humantivMedit() public view returns (uint256) {
    return token_.balanceOf(address(this));
  }

  function requestIssuance(uint256 _value)
    onlyHumantivRole
    whenNotPaused
    public
    returns (bool)
  {
    releaseAmount_ = _value;
    releaseRequestTime_ = now;
    emit IssuanceRequested(msg.sender, _value);
    return true;
  }

  function issueMedit(address _to, uint256 _value)
    onlyHumantivRole
    whenNotPaused
    public
    returns (bool)
  {
    require(_value <= releaseAmount_);    
    require(now > releaseRequestTime_.add(releaseTimeLock_));
    token_.transfer(_to, _value);
    releaseAmount_ = releaseAmount_.sub(_value);
    emit MeditIssued(_to, _value);
    return true;
  }

  function rescueMedit(address _from, uint256 _value)
    onlyHumantivRole
    whenNotPaused
    public
    returns (bool)
  {
    token_.transferFrom(_from, address(this), _value);
    emit MeditRescued(_from, _value);
    return true;
  }

  function addHumantivRole(address _account)
    onlyHumantivRole
    whenNotPaused
    public
    returns (bool)
  {
    humantivRole_.add(_account);
    emit HumantivRoleAdded(_account, msg.sender);
    return true;
  }

  function removeHumantivRole(address _from)
    onlyHumantivRole
    whenNotPaused
    public
    returns (bool)
  {
    humantivRole_.remove(_from);
    emit HumantivRoleRemoved(_from, msg.sender);
    return true;
  }

  function setTimeLock(uint256 _timeLock)
    onlyOwner
    public
    returns (bool)
  {
    releaseTimeLock_ = _timeLock;
    emit ReleaseTimeLockUpdated(_timeLock);
    return true;
  }

  function transferOwnership(address _newOwner)
    onlyOwner    
    public
  {
    addPauser(_newOwner);
    renouncePauser();
    super.transferOwnership(_newOwner);
  }

  event HumantivRoleAdded(address indexed account, address indexed by);
  event HumantivRoleRemoved(address indexed account, address indexed by);
  event MeditReleaseRequested(address indexed by,
                              uint256 indexed amount,
                              uint256 indexed at);
  event ReleaseTimeLockUpdated(uint256 value);
  event MeditIssued(address indexed to, uint256 indexed value);
  event MeditRescued(address indexed from, uint256 value);
  event IssuanceRequested(address indexed by, uint256 indexed value);
}
