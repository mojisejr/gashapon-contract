//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFT1 is ERC721 {
    uint256 currentTokenId = 0;
    constructor() ERC721("NFT1", "NFT") {
    }

    function increaseTokenId() public {
        currentTokenId = currentTokenId + 1;
    }

    function getCurrentTokenId() public view returns(uint256) {
        return currentTokenId + 1;
    }

    function mint() public {
        uint256 tokenId = getCurrentTokenId();
        _mint(msg.sender, tokenId);
        increaseTokenId();
    }
} 