// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";


interface IFactory {
  function devAddr() external pure returns (address);

  function feePercent() external pure returns (uint256);

  function MAX_FEE() external pure returns (uint256);

  function randomNonce() external view returns (bytes32);

}


contract LuckBox is
  Ownable,
  ReentrancyGuard,
  IERC721Receiver,
  ERC165Storage,
  ERC721Holder
{
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  // for identification purposes
  string public name;
  string public symbol;

  uint256 public ticketPrice;

  // Slot info
  struct Slot {
    address assetAddress;
    uint256 tokenId;
    bool locked;
    bool pendingWinnerToClaim;
    address winner;
  }

  mapping(uint256 => Slot) public list;

  // History data
  struct Result {
    bytes32 requestId;
    address drawer;
    bool won;
    uint256 slot;
  }

  mapping(uint256 => Result) public result;
  uint256 public resultCount;

  // Reserve slots
  struct ReserveNft {
    address assetAddress;
    uint256 tokenId;
  }

  mapping(uint256 => ReserveNft) public reserveQueue;
  uint256 public firstQueue = 1;
  uint256 public lastQueue = 0;

  uint256 public constant MAX_SLOT = 9;

  uint256 nftInSlotCount;

  // factory address
  IFactory public factory;

  event UpdatedTicketPrice(uint256 ticketPrice);
  event Draw(address indexed drawer, bytes32 requestId);
  event ClaimNft(address indexed receiver, address factory, address tokenId);
  event DepositedNft(
    uint256 slotId,
    address assetAddress,
    uint256 tokenId
  );
  event WithdrawnNft(uint256 slotId);
  event Drawn(
    address indexed drawer,
    bool won,
    address assetAddress,
    uint256 tokenId
  );
  event Claimed(uint256 slotId, address winner);
  event StackedNft(
    address assetAddress,
    uint256 tokenId
  );

  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _ticketPrice,
    address _factory
  ) {
    require(_ticketPrice != 0, "Invalid ticket price");

    name = _name;
    symbol = _symbol;
    ticketPrice = _ticketPrice;
    factory = IFactory(_factory);
    _registerInterface(IERC721Receiver.onERC721Received.selector);
  }

  // pays $MATIC to draws a gacha
  function draw(bytes32[] memory proofs, bytes32 leafNode) public payable nonReentrant {
    require(msg.value == ticketPrice, "Payment is not attached");
    require(proofs.length > 0, "invalid proofs");
    require(MerkleProof.verify(proofs, factory.randomNonce(), leafNode), 'invalid merkle info');

    if (address(factory) != address(0)) {
      uint256 feeAmount = ticketPrice.mul(factory.feePercent()).div(10000);
      _safeTransferETH(factory.devAddr(), feeAmount);
    }

    uint256 hashRandomNumber = uint256(
      keccak256(
        abi.encodePacked(block.timestamp, msg.sender, factory.randomNonce(), leafNode, address(this))
      )
    );

    _draw(hashRandomNumber, msg.sender, "0x00");

    emit Draw(msg.sender, "0x00");
  }

  // // find the current winning rates
  // function winningRates() public view returns (uint256) {
  //   uint256 increment = 0;
  //   for (uint8 i = 0; i < MAX_SLOT; i++) {
  //     Slot storage slot = list[i];

  //     if (slot.locked && slot.pendingWinnerToClaim == false) {
  //       increment += slot.randomnessChance;
  //     }
  //   }
  //   return increment;
  // }

  function parseRandomUInt256(uint256 input) public view returns (uint256) {
    return _parseRandomUInt256(input);
  }

  // check total ETH locked in the contract
  function totalEth() public view returns (uint256) {
    return address(this).balance;
  }

  // make a claim for an eligible winner
  function _claimNft(uint256 _slotId) internal {
    require(MAX_SLOT > _slotId, "Invalid slot ID");
    require(list[_slotId].locked == true, "The slot is empty");
    require(list[_slotId].pendingWinnerToClaim == true, "Still has no winner");
    require(list[_slotId].winner == msg.sender, "The caller is not the winner");
    require(nftInSlotCount > 0, "no nft to be claimed");

    // console.log("before claim: %s", nftInSlotCount);

    IERC721(list[_slotId].assetAddress).safeTransferFrom(
        address(this),
        msg.sender,
        list[_slotId].tokenId
    );

    //update current avaliable nft amount
    --nftInSlotCount;
    // console.log("after claim: %s", nftInSlotCount);

    list[_slotId].locked = false;
    list[_slotId].assetAddress = address(0);
    list[_slotId].tokenId = 0;
    list[_slotId].pendingWinnerToClaim = false;
    list[_slotId].winner = address(0);


    if (lastQueue >= firstQueue) {
      ReserveNft memory reserve = _dequeue();

      ++nftInSlotCount;

      list[_slotId].locked = true;
      list[_slotId].assetAddress = reserve.assetAddress;
      list[_slotId].tokenId = reserve.tokenId;
      list[_slotId].pendingWinnerToClaim = false;
      list[_slotId].winner = address(0);
    }
    emit Claimed(_slotId, msg.sender);
  }

  // ONLY OWNER CAN PROCEED

  // for local testing
  // _randomNumber must be in between 0 - 2^10**256
  function forceDraw(uint256 _randomNumber)
    public
    payable
    nonReentrant
  {
    // require(msg.value == ticketPrice, "Payment is not attached");

    // if (address(factory) != address(0)) {
    //   uint256 feeAmount = ticketPrice.mul(factory.feePercent()).div(10000);
    //   _safeTransferETH(factory.devAddr(), feeAmount);
    // }

    _draw(_randomNumber, msg.sender, "0x00");
  }

  function withdrawAllEth() public onlyOwner nonReentrant {
    uint256 amount = address(this).balance;
    _safeTransferETH(msg.sender, amount);
  }

  function setTicketPrice(uint256 _ticketPrice) public onlyOwner nonReentrant {
    require(_ticketPrice != 0, "Invalid ticket price");

    ticketPrice = _ticketPrice;
    emit UpdatedTicketPrice(_ticketPrice);
  }

  // randomness value -> 1% = 100, 10% = 1000 and not allows more than 10% per each slot
  function depositNft(
    uint8 _slotId,
    address _assetAddress,
    uint256 _tokenId
  ) public nonReentrant onlyOwner {
    require(MAX_SLOT > _slotId, "Invalid slot ID");

    require(list[_slotId].locked == false, "The slot is occupied");

    // take the NFT
    IERC721(_assetAddress).safeTransferFrom(
        msg.sender,
        address(this),
        _tokenId
    );
    
    ++nftInSlotCount;

    list[_slotId].locked = true;
    list[_slotId].assetAddress = _assetAddress;
    list[_slotId].tokenId = _tokenId;
    list[_slotId].pendingWinnerToClaim = false;


    emit DepositedNft(_slotId, _assetAddress, _tokenId);
  }

  function withdrawNft(uint256 _slotId) public nonReentrant onlyOwner {
    require(MAX_SLOT > _slotId, "Invalid slot ID");
    require(list[_slotId].locked == true, "The slot is empty");
    require(
      list[_slotId].pendingWinnerToClaim == false,
      "The asset locked is being claimed by the winner"
    );

    IERC721(list[_slotId].assetAddress).safeTransferFrom(
        address(this),
        msg.sender,
        list[_slotId].tokenId
    );

    --nftInSlotCount;

    list[_slotId].locked = false;
    list[_slotId].assetAddress = address(0);
    list[_slotId].tokenId = 0;
    list[_slotId].pendingWinnerToClaim = false;

    emit WithdrawnNft(_slotId);
  }

  function stackNft(
    address _assetAddress,
    uint256 _tokenId
  ) public {
    // take the NFT
    IERC721(_assetAddress).safeTransferFrom(
        msg.sender,
        address(this),
        _tokenId
    );

    ReserveNft memory reserve = ReserveNft({
      assetAddress: _assetAddress,
      tokenId: _tokenId
    });

    _enqueue(reserve);

    emit StackedNft(_assetAddress, _tokenId);
  }

  function withdrawERC20(address _tokenAddress, uint256 _amount)
    public
    onlyOwner
  {
    IERC20(_tokenAddress).safeTransfer(msg.sender, _amount);
  }

  function withdrawERC721(address _tokenAddress, uint256 _tokenId)
    public
    onlyOwner
  {
    IERC721(_tokenAddress).safeTransferFrom(
      address(this),
      msg.sender,
      _tokenId
    );
  }
  // PRIVATE FUNCTIONS

  function _parseRandomUInt256(uint256 input) internal view returns (uint256) {
    return input.mod(nftInSlotCount);
  }

  // function _draw(
  //   uint256 _randomNumber,
  //   address _drawer,
  //   bytes32 _requestId
  // ) internal {
  //   uint256 parsed = _parseRandomUInt256(_randomNumber); // parse into 0-10000 or 0.00-100.00%
  //   uint256 increment = 0;
  //   bool won = false;
  //   uint8 winningSlot = 0;
  //   address winningAssetAddress = address(0);
  //   uint256 winningTokenId = 0;

  //   for (uint8 i = 0; i < MAX_SLOT; i++) {
  //     Slot storage slot = list[i];
  //     if (slot.locked && slot.pendingWinnerToClaim == false) {
  //       increment += slot.randomnessChance;
  //       // keep incrementing until the random number has been hitted
  //       if (increment > parsed && !won) {
  //         slot.pendingWinnerToClaim = true;
  //         slot.winner = _drawer;

  //         won = true;
  //         winningSlot = i;
  //         winningAssetAddress = slot.assetAddress;
  //         winningTokenId = slot.tokenId;
  //         _claimNft(winningSlot);
  //       }
  //     }
  //   }

  //   // keep track of the result
  //   result[resultCount].requestId = _requestId;
  //   result[resultCount].drawer = _drawer;
  //   result[resultCount].won = won;
  //   result[resultCount].slot = winningSlot;
  //   result[resultCount].output = parsed;
  //   result[resultCount].eligibleRange = increment;

  //   resultCount += 1;

  //   emit Drawn(_drawer, won, winningAssetAddress, winningTokenId);
  // }


  //new draw
  function _draw(
    uint256 _randomNumber,
    address _drawer,
    bytes32 _requestId
  ) internal {

    //random the slot number of the available array
    uint256 winningSlot = _parseRandomUInt256(_randomNumber); //random slot 
    // console.log("winning slot: %s", winningSlot);

    //prepare the slot array
    uint256[] memory availableSlot = new uint256[](nftInSlotCount);

    //loop and check if the slot is empty or not?, if not push it to array
    for(uint256 i = 0; i < MAX_SLOT;) {
      if(list[i].locked == true) {
        availableSlot[i] = i;
      }
      unchecked {
         ++i;
      }
    }

    //get slot tobe claimed
    uint256 tobeClaimed = availableSlot[winningSlot];
    list[tobeClaimed].pendingWinnerToClaim = true;
    list[tobeClaimed].winner = msg.sender;

    // console.log("token to be claimed: %s", tobeClaimed);

    //inner claim function with won slot
    _claimNft(tobeClaimed);

    // keep track of the result
    result[resultCount].requestId = _requestId;
    result[resultCount].drawer = _drawer;
    result[resultCount].won = true;
    result[resultCount].slot = winningSlot;

    resultCount += 1;

    emit Drawn(_drawer, true, list[winningSlot].assetAddress, list[winningSlot].tokenId);
  }


  function _enqueue(ReserveNft memory _data) private {
    lastQueue += 1;
    reserveQueue[lastQueue] = _data;
  }

  function _dequeue() private returns (ReserveNft memory) {
    require(lastQueue >= firstQueue); // non-empty queue

    ReserveNft memory data = ReserveNft({
      assetAddress: reserveQueue[firstQueue].assetAddress,
      tokenId: reserveQueue[firstQueue].tokenId
    });

    delete reserveQueue[firstQueue];
    firstQueue += 1;
    return data;
  }

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{ value: value }(new bytes(0));
    require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
  }

  //CUSTOM
  function getNFTinSlotCount() public view returns(uint256) {
    return nftInSlotCount;
  }
}
