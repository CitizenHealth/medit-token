pragma solidity ^0.5.1;

import "./MeditToken.sol";
import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


contract CHMeditPool {
  using Roles for Roles.Role;
  using SafeMath for uint256;

  struct Signatures {
    uint256 nonce;
    uint256 number;
    mapping (uint256 => mapping (address => bool)) signatories;
  }

  MeditToken private token_;
  Roles.Role private signers_;
  uint256 private signerCount_;
  mapping (bytes32 => Signatures) private signaturesByCall_;
  uint256 private requiredSignatures_;

  constructor (MeditToken _token) public {
    token_ = _token;
    signers_.add(msg.sender);
    signerCount_ = 1;
    requiredSignatures_ = 1;
  }

  modifier multiSig() {
    require(signers_.has(msg.sender));
    bytes32 hash = keccak256(msg.data);    
    bool signed = sign(hash);
    
    if (signed) {
      _;
      emit FunctionExecuted(hash, signaturesByCall_[hash].nonce);
    }
  }

  function sign(bytes32 _hash) internal returns (bool) {
    Signatures storage sigs = signaturesByCall_[_hash];
    if (sigs.signatories[sigs.nonce][msg.sender]) { // revoke signature
      sigs.number = sigs.number.sub(1);
      sigs.signatories[sigs.nonce][msg.sender] = false;
      emit FunctionSigned(_hash, sigs.nonce, msg.sender);
      return false;
    } else { // sign
      sigs.number = sigs.number.add(1);
      sigs.signatories[sigs.nonce][msg.sender] = true;
      emit FunctionSigned(_hash, sigs.nonce, msg.sender);
      if (sigs.number >= requiredSignatures_) {
        sigs.number = 0;
        sigs.nonce = sigs.nonce.add(1); // threshold reached
        return true;
      } else {
        return false;
      }
    }
  }

  function addSigner(address _account)
    multiSig
    public
    returns (bool)
  {
    signerCount_ = signerCount_.add(1);
    signers_.add(_account);
    emit SignerAdded(_account, msg.sender);
    return true;
  }

  function removeSigner(address _account)
    multiSig
    public
    returns (bool)
  {
    require(_account != msg.sender); // can't remove self  
    signerCount_ = signerCount_.sub(1);
    if (signerCount_ < requiredSignatures_) {
      requiredSignatures_ = signerCount_;
    }
    assert(signerCount_ > 0);
    signers_.remove(_account);
    emit SignerRemoved(_account);
    return true;
  }

  function changeRequiredSignatures(uint256 _number)
    multiSig
    public
    returns (bool)
  {
    require(_number <= signerCount_);
    requiredSignatures_ = _number;
    return true;
  }
  
  function mintTokens(uint256 _amount)
    multiSig
    public
    returns (bool)
  {
    token_.mint(address(this), _amount);
    emit TokensMinted(_amount);    
    return true;
  }

  function transferTokens(address _to, uint256 _value)
    multiSig
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= token_.balanceOf(address(this)));
    token_.transfer(_to, _value);
    emit TokensTransferred(_to, _value);
    return true;
  }

  function burnTokens(uint256 _value)
    multiSig
    public
    returns (bool)
  {
    require(_value <= token_.balanceOf(address(this)));
    token_.burn(_value);
    emit TokensBurned(_value);
    return true;
  }

  function addMinterRoke(address _minter)
    multiSig
    public
    returns (bool)
  {
    token_.addMinter(_minter);
    emit MinterAdded(_minter);
    return true;
  }

  event SignerAdded(address indexed signer, address indexed by);
  event SignerRemoved(address indexed signer);
  event TokensMinted(uint256 indexed amount);
  event TokensTransferred(address indexed to, uint256 indexed amount);
  event TokensBurned(uint256 indexed amount);
  event FunctionSigned(bytes32 indexed hash,
                       uint256 indexed nonce,
                       address indexed by);
  event FunctionExecuted(bytes32 indexed hash, uint256 indexed nonce);
  event MinterAdded(address indexed minter);
}
