export const abi = [
  "function getAllBoxes() view returns(tuple(string name, string symbol, address owner, address contractAddress, bool isBanned, bool isApproved)[] memory)",
  "function boxesCount() view returns(uint256)",
  "function setBan(uint256 _boxId, bool _value)",
  "function setApprove(uint256 _boxId, bool _value)",
  "function setFee(uint256 _feeAmount)",
  "function setDevAddress(address _newAddress)",
  "function getBoxOwner(uint256 _boxId) view returns(address)",
  "function getBoxContractAddress(uint256 _boxId) view returns(address)",
  "function getBoxName(uint256 _boxId) view returns(string memory)",
  "function getBoxSymbol(uint256 _boxId) view returns(string memory)",
  "function isBanned(uint256 _boxId) view returns(bool)",
  "function isApproved(uint256 _boxId) view returns(bool)",
  "function createNewBox(string memory, string memory, uint256)",
  "function getCurrentBoxId() view returns(uint256)",
];

export const address = "0xC76164c120750F7B8dbC73B51e3A23Fe39a83266";
