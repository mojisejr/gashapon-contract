const { expect } = require("chai");
const { ethers } = require("hardhat");

let box;
let nft;
let owner;

describe("kPunkBox contract testing", () => {
  before(async () => {
    [owner] = await ethers.getSigners();
    let nftFactory = await ethers.getContractFactory("NFT1");
    let boxFactory = await ethers.getContractFactory("kPunkBox");

    //Deploy and mint nft to owner;
    nft = await nftFactory.deploy();
    await nft.deployed();

    //mint some nfts
    await nft.mint(1);
    await nft.mint(2);
    await nft.mint(3);

    box = await boxFactory.deploy(
      "kPunkBox No.1",
      "KPUNK",
      ethers.utils.parseEther("0.01"),
      ethers.constants.AddressZero
    );

    await box.deployed();

    console.log("deployed addresses:", {
      nft: nft.address,
      box: box.address,
    });
  });

  it("check box initial parameter", async () => {
    expect((await box.name()).toString()).to.equal("kPunkBox No.1");
    expect((await box.symbol()).toString()).to.equal("KPUNK");
    expect((await box.ticketPrice()).toString()).to.equal(
      ethers.utils.parseEther("0.01").toString()
    );
  });

  it("should be able to deposit nft to kPunkBox", async () => {
    // function depositNFT(uint8 _slotId, address _nftAddress, uint256 _tokenId, uint256 _randomness) public nonReentrant onlyOwner
    //approve
    let slotId = 0;
    await nft.setApprovalForAll(box.address, true);
    await box.depositNFT(slotId, nft.address, 1, 1000);

    const { nftAddress, tokenId, isLocked, isWon, chance, winner } =
      await box.list(slotId);

    console.log("slot data:", {
      nftAddress,
      tokenId: tokenId.toString(),
      isLocked,
      isWon,
      chance: chance.toString(),
      winner,
    });

    expect(nft.address).to.equal(nftAddress);
  });
});
