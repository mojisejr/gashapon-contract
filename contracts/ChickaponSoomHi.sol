//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract ChickaponSoomHai is Ownable {

  using Strings for uint256;

  string seed = "chickaponwillrulethekub";

  constructor() {}

  function changeSeed(string memory _newSeed) public onlyOwner {
    seed = _newSeed;
  }

  function getRandomNumber() public view returns(uint256) {
     return uint256(keccak256(abi.encodePacked(seed, block.timestamp.toString(), block.number)));
  }
}