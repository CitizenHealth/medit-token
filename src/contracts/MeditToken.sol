pragma solidity ^0.5.1;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";


contract MeditToken is ERC20Detailed("Medit Test", "tMDT1", 18),
  ERC20Mintable,
  ERC20Burnable {
}
