// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./kPunkBox.sol";


/**
 * @title Factory for creating new luckbox contract.
 */

contract kPunkBoxFactory is ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;

  struct Box {
    string name;
    string symbol;
    address owner;
    address contractAddress;
    bool banned;
    bool approved;
  }

  Box[] public boxes;
  uint256 public totalBoxes;

  // Fee section
  address public devAddr;
  address public treasuryAddr;
  uint256 public devFeePercent = 150; // 1.5%
  uint256 public treasuryFeePercent = 150; //1.5%
  uint256 public constant MAX_FEE = 1000; // 10%

  uint256 public COOLDOWN = 3 seconds;
  uint256 public timestamp;

  //nonce for only dev purpose
  bytes32 public randomNonce = 0xd28e8860b2ebd608c02124274c0d9988d526a48f7f6ac34b51edd7e187e04610;

  event kPunkBoxCreated(address indexed _address);
  event SetFee(uint256 _fee);
  event SetDevAddr(address _devAddr);
  event RequestedNonce(address user, uint256 timestamp);

  constructor(address _devAddr, address _treasuryAddr) 
  {
    require(_devAddr != address(0), "Address is zero");
    require(_treasuryAddr != address(0), "Address is zero");
    devAddr = _devAddr;
    treasuryAddr = _treasuryAddr;
  }

  function createkPunkbox(
    string calldata name,
    string calldata symbol,
    uint256 ticketPrice
  ) external nonReentrant {
    LuckBox luckbox = new LuckBox(name, symbol, ticketPrice, address(this));

    luckbox.transferOwnership(msg.sender);

    address newkPunkBox = (address(luckbox));

    boxes.push(
      Box({
        name: name,
        symbol: symbol,
        owner: msg.sender,
        contractAddress: newkPunkBox,
        banned: false,
        approved: false
      })
    );

    totalBoxes += 1;

    timestamp = block.timestamp;

    emit kPunkBoxCreated(newkPunkBox);
  }

  function getAllBoxes() external view returns(Box[] memory) {
    return boxes;
  }

  function getBoxCount() external view returns(uint256) {
    return boxes.length;
  }

  function getBoxOwner(uint256 _id) public view returns (address) {
    return boxes[_id].owner;
  }

  function getBoxContractAddress(uint256 _id) public view returns (address) {
    return boxes[_id].contractAddress;
  }

  function getBoxName(uint256 _id) public view returns (string memory) {
    return boxes[_id].name;
  }

  function getBoxSymbol(uint256 _id) public view returns (string memory) {
    return boxes[_id].symbol;
  }

  function isBanned(uint256 _id) public view returns (bool) {
    return boxes[_id].banned;
  }

  function isApproved(uint256 _id) public view returns (bool) {
    return boxes[_id].approved;
  }

  // ADMIN FUNCTIONS
  function setRandomNonce(bytes32 _newNonce) public onlyOwner {
    randomNonce = _newNonce;
  }

  function setDevAddr(address _devAddr) public onlyOwner nonReentrant {
    require(_devAddr != address(0), "Address zero !");
    devAddr = _devAddr;

    emit SetDevAddr(devAddr);
  }

  function setDevFee(uint256 _feePercent) public onlyOwner nonReentrant {
    require(_feePercent <= MAX_FEE, "Below MAX_FEE Please");
    devFeePercent = _feePercent;

    emit SetFee(devFeePercent);
  }

  function setTreasuryFee(uint256 _feePercent) public onlyOwner nonReentrant {
    require(_feePercent <= MAX_FEE, "Below MAX_FEE Please");
    treasuryFeePercent = _feePercent;
    emit SetFee(treasuryFeePercent);
  }

  function setTreasuryAddress(address _newTreasury) public onlyOwner nonReentrant {
    require(_newTreasury != address(0), "invalid address");
    treasuryAddr = _newTreasury; 
  }


  function setBan(uint256 _id, bool _isBan) public onlyOwner nonReentrant {
    boxes[_id].banned = _isBan;
  }

  function setApprove(uint256 _id, bool _isApprove)
    public
    onlyOwner
    nonReentrant
  {
    boxes[_id].approved = _isApprove;
  }
}
