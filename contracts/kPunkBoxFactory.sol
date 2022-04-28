//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./kPunkBox.sol";



contract kPunkBoxFactory is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct Box {
        string name;
        string symbol;
        address owner;
        address contractAddress;
        bool isBanned;
        bool isApproved;
    }

    //must be array for easier to fetch all boxes
    // mapping(uint256 => Box) public boxes;
    Box[] public boxes;
    uint256 currentBoxId = 0;

    uint256 feePercent = 300;
    uint256 MAX_FEE = 1000;

    address devAddress;

    event BoxCreated(address indexed owner, uint256 boxId, string name, address contractAddress);
    event SetFee(uint256 newFee);
    event SetDevAddress(address newAddress);

    constructor() {
        devAddress = msg.sender;
    }

    function getAllBoxes() public view returns(Box[] memory) {
        require(boxes.length > 0 ,"boxes is empty");
        return boxes;
    }

    function boxesCount() public view returns(uint256) {
        if(boxes.length > 0) {
            return boxes.length;
        } else {
            return 0;
        }
    }

    function createNewBox(string memory _name, string memory _symbol, uint256 _ticketPrice) external nonReentrant {
        require(_ticketPrice > 0, "invalid ticket price");
        uint256 currentBox = getCurrentBoxId();

        kPunkBox box = new kPunkBox(_name, _symbol, _ticketPrice, address(this));

        address newBoxAddress = address(box); 

        // boxes[currentBox].name = _name;
        // boxes[currentBox].symbol = _symbol;
        // boxes[currentBox].owner = msg.sender;
        // boxes[currentBox].contractAddress = newBoxAddress;
        // boxes[currentBox].isBanned = false;
        // boxes[currentBox].isApproved = true;


        boxes.push(
            Box (
                _name,
                _symbol,
                msg.sender,
                newBoxAddress,
                false,
                true
            )
        );

        increaseBoxId();

        emit BoxCreated(msg.sender, currentBox, _name, newBoxAddress);
    }


    function setBan(uint256 _boxId, bool _value) public onlyOwner { 
        boxes[_boxId].isBanned = _value;
    }

    function setApprove(uint256 _boxId, bool _value) public onlyOwner {
        boxes[_boxId].isApproved = _value;
    }

    function setFee(uint256 _feeAmount) public onlyOwner {
        require(_feeAmount < MAX_FEE, "setFee: invalid fee");
        feePercent = _feeAmount;

        emit SetFee(_feeAmount);
    }

    function setDevAddress(address _newAddress) public onlyOwner {
        require(_newAddress != address(0), "setDevAddress: invalid address");
        devAddress = _newAddress;

        emit SetDevAddress(_newAddress);
    }
    
    function getCurrentBoxId() public view returns(uint256) {
        return currentBoxId + 1;
    }

    function increaseBoxId() internal {
        currentBoxId += 1;
    }

    function getBoxOwner(uint256 _boxId) public view returns(address) {
        return boxes[_boxId].owner;
    }

    function getBoxContractAddress(uint256 _boxId) public view returns(address) {
        return boxes[_boxId].contractAddress;
    }

    function getBoxName(uint256 _boxId) public view returns(string memory) {
        return boxes[_boxId].name;
    }

    function getBoxSymbol(uint256 _boxId) public view returns(string memory) {
        return boxes[_boxId].symbol;
    }

    function isBanned(uint256 _boxId) public view returns(bool) {
        return boxes[_boxId].isBanned;
    }

    function isApproved(uint256 _boxId) public view returns(bool) {
        return boxes[_boxId].isApproved;
    }
}
