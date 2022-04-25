//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IFactory {
    function devAddress() external pure returns (address);
    function feePercent() external pure returns (uint256);
    function MAX_FEE() external pure returns (uint256);
    // function randomNonce() external view returns (uint256);
}

//Done
//1 deposit NFT to the gashapon 
//2 widraw NFT from not empty slot
//3 draw NFT from gashapon
//4 check contract balance (KUB)
//5 update ticket price 
//6 withdraw ETH and ERC20 from contract
//7 check winning rate from avaliable gashapon


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
    IFactory factory;

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
    event Draw(address indexed drawer);
    event Drawn(address indexed drawer, bool won, address nftAddress, uint256 tokenId);
    event WithdrawnNFT(uint8 slotId);
    event UpdateTicketPrice(uint256 newPrice);
    event ERC20Withdrawn(uint256 amounts, address to);
    event KUBWithdrawn(uint256 amounts, address to);

    constructor(string memory _name, string memory _symbol, uint256 _ticketPrice, address _factory) { 
        name = _name;
        symbol = _symbol;
        ticketPrice = _ticketPrice;
        factory = IFactory(_factory);
    }

    function setTicketPrice(uint256 _price) public onlyOwner {
        require(_price > 0, "setTicketPrice: invalid price");

        ticketPrice = _price;

        emit UpdateTicketPrice(_price);
    }

    function withdrawAllKUB() public payable nonReentrant onlyOwner {
        uint256 amounts = address(this).balance;
        _safeTransferETH(msg.sender, amounts);
    }

    function withdrawAllERC20(address _erc20) public nonReentrant onlyOwner {
        IERC20 erc20 = IERC20(_erc20);
        uint256 amounts = erc20.balanceOf(address(this));
        require(amounts > 0, "withdrawAllERC20: nothing in this contract");

        erc20.transfer(msg.sender, amounts);

        emit ERC20Withdrawn(amounts, msg.sender);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
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

    //for development purpose
    function getRandomNumber() public pure returns(uint256) {
        uint256 rand = uint256(keccak256(abi.encodePacked("seed")));
        return rand.mod(10000);
    }

    function getWinningRates() public view returns(uint256) {
        uint256 increment = 0;
        for(uint8 i = 0; i < MAX_SLOT;) {
            Slot memory slot = list[i];

            if(slot.isLocked && !slot.isWon) {
                increment += slot.chance;
            }
            unchecked {
                ++i;
            }
        }

        return increment;
    }

    function withdrawNFT(uint8 _slotId) public nonReentrant onlyOwner {
        //1 won token cannot be withdrawn
        //2 only available slot could be withdrawn
        require(_slotId < MAX_SLOT, "invalid slot id");
        require(list[_slotId].isLocked, "withdrawNFT: this slot is empty");
        require(!list[_slotId].isWon, "withdrawNFT: Won slot could not be withdrawn");

        IERC721(list[_slotId].nftAddress).safeTransferFrom(address(this), msg.sender, list[_slotId].tokenId);


        //3 clear slot after nft has withdrawn
        list[_slotId].isLocked = false;
        list[_slotId].nftAddress = address(0);
        list[_slotId].tokenId = 0;
        list[_slotId].chance = 0;
        list[_slotId].winner = address(0);

        emit WithdrawnNFT(_slotId);
    }

    // function drawWithERC20() public nonReentrant{
    //     _draw();
    // }

    function drawWithKUB () payable public nonReentrant {
        require(msg.value == ticketPrice, "drawWithKUB: invalid price");
        
        //fee operate here
        if (address(factory) != address(0)) {
            uint256 feeAmount = ticketPrice.mul(factory.feePercent()).div(10000);
            _safeTransferETH(factory.devAddress(), feeAmount);
        }

        _draw();

        emit Draw(msg.sender);
    }

    function _draw() internal {

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

    //must be internal on production
    function claimNFT(uint8 slotId) public {
        require(list[slotId].isLocked, "ClaimNFT: this slot is empty");
        require(list[slotId].isWon, "ClaimNFT: only won nft is claimable");
        require(list[slotId].winner == msg.sender, "ClaimNFT: only winner could be able to claim");


        IERC721(list[slotId].nftAddress).safeTransferFrom(address(this), msg.sender, list[slotId].tokenId);
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{ value: value }(new bytes(0));
        require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
    }
}