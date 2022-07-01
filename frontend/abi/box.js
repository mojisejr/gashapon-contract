export const abi = [
  "function list(uint8) view returns(tuple(address nftAddress, uint256 tokenId, bool isLocked, bool isWon, uint256 chance, address winner) memory)",
  "function depositNFT(uint8 _slotId, address _nftAddress, uint256 _tokenId, uint256 _randomness)",
  "function getWinningRates() view returns(uint256)",
  "function withdrawNFT(uint8 _slotId)",
  "function drawWithKUB() payable",
  "function getBalance() returns(uint256)",
  "function setTicketPrice(uint256 _price)",
];

export const address = "0xcB6635bA42163C0E5f0a17E95a5C6b25044dF463";
