//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFT1 is ERC721 {
    constructor() ERC721("NFT1", "NFT") {
    }

    function mint(uint256 tokenId) public {
        require(!_exists(tokenId), "token is existed!"); 
        _mint(msg.sender, tokenId);
    }
} 