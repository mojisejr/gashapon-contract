//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract kPunkBox is Ownable,
ReentrancyGuard,
IERC721Receiver,
ERC165,
ERC721Holder
{


    using SafeMath for uint256;

    //Box Info
    string public name;
    string public symbol;
    uint256 public ticketPrice;
    address factory;

    //MAX slot is 9
    struct Slot {
        address nftAddress;
        uint256 tokenId;
        bool isLocked; //false: empty, true: occupied
        bool isWon;
        uint256 chance;
        address winner;
    }

    mapping(uint8 => Slot) public list;
    uint8 public MAX_SLOT = 9;


    struct Result {
        address drawer;
        uint256 tokenId;
        uint256 drawTimestamp;
        bool isWon;
        uint256 chance;
        uint256 eligibleRange;
    }

    mapping(uint256 => Result) public results;
    uint256 resultCount = 0;


    event DepositedNFT(uint8 slotId, address nftAddress, uint256 tokenId, uint256 randomness);
    event Drawn(address drawer, bool won, address nftAddress, uint256 tokenId);

    constructor(string memory _name, string memory _symbol, uint256 _ticketPrice, address _factory) { 
        name = _name;
        symbol = _symbol;
        ticketPrice = _ticketPrice;
        factory = _factory;
    }

    function depositNFT(uint8 _slotId, address _nftAddress, uint256 _tokenId, uint256 _randomness) public nonReentrant onlyOwner {
        require(_slotId < MAX_SLOT, "depositNFT: invalid slot Id.");
        require(!list[_slotId].isLocked, "depositNFT: this slot is occupied");
        require(_randomness > 0 && _randomness < 2001, "depositNFT: randomness cannot more than 2000");

        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

        list[_slotId].nftAddress = _nftAddress;
        list[_slotId].tokenId = _tokenId;
        list[_slotId].isLocked = true;
        list[_slotId].isWon = false;
        list[_slotId].chance = _randomness;
        list[_slotId].winner = address(0);

        emit DepositedNFT(_slotId, _nftAddress, _tokenId, _randomness);
    }

    function getRandomNumber() public pure returns(uint256) {
        uint256 rand = uint256(keccak256(abi.encodePacked("seed")));
        return rand.mod(10000);
    }

    function draw() public {

        uint256 rand = getRandomNumber();
        uint256 target = 0;
        bool won = false;
        address winningNftAddress = address(0);
        uint8 winningSlot = 0;
        uint256 winningTokenId = 0; 

        for (uint8 i = 0; i < MAX_SLOT;) {
            Slot storage slot = list[i];
            if(slot.isLocked && !slot.isWon)  {
                target += slot.chance;
                if(target > rand && !won) {
                    slot.isWon = true;
                    slot.winner = msg.sender;

                    won = true;
                    winningNftAddress = slot.nftAddress;
                    winningSlot = i;
                    winningTokenId = slot.tokenId;
                    claimNFT(winningSlot);
                }
            }
            unchecked {
                ++i;
            }
        }

        results[resultCount].drawer = msg.sender;
        results[resultCount].tokenId = winningTokenId;
        results[resultCount].drawTimestamp = block.timestamp;
        results[resultCount].isWon = won;
        results[resultCount].chance = rand;
        results[resultCount].eligibleRange = target;

        ++resultCount;

        emit Drawn(msg.sender, won, winningNftAddress, winningTokenId);
    }

    function claimNFT(uint8 slotId) public {
        require(list[slotId].isLocked, "ClaimNFT: this slot is empty");
        require(list[slotId].isWon, "ClaimNFT: only won nft is claimable");
        require(list[slotId].winner == msg.sender, "ClaimNFT: only winner could be able to claim");


        IERC721(list[slotId].nftAddress).safeTransferFrom(address(this), msg.sender, list[slotId].tokenId);
    }
}