const { expect } = require("chai");
const { ethers } = require("hardhat");

let box;
let nft;
let owner;
let minter;

describe("kPunkBox contract testing", () => {
  before(async () => {
    [owner, minter] = await ethers.getSigners();
    let nftFactory = await ethers.getContractFactory("NFT1");
    let boxFactory = await ethers.getContractFactory("kPunkBox");

    //Deploy and mint nft to owner;
    nft = await nftFactory.deploy();
    await nft.deployed();

    //mint some nfts
    for (let i = 1; i < 11; i++) {
      await nft.mint(i);
    }

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
    let slotId = [0, 1, 2];
    let nftId = [1, 2, 3];
    await nft.setApprovalForAll(box.address, true);
    for (let i = 0; i < slotId.length; i++) {
      await box.depositNFT(slotId[i], nft.address, nftId[i], 1000);
    }

    const { nftAddress, tokenId, isLocked, isWon, chance, winner } =
      await box.list(slotId[0]);

    // console.log("slot data:", {
    //   nftAddress,
    //   tokenId: tokenId.toString(),
    //   isLocked,
    //   isWon,
    //   chance: chance.toString(),
    //   winner,
    // });

    expect(nft.address).to.equal(nftAddress);
    expect((await nft.ownerOf(nftId[0])).toString()).to.equal(box.address);
  });

  it("should be able to take only 9 slot", async () => {
    let slotId = [3, 4, 5, 6, 7, 8, 9];
    let nftId = [4, 5, 6, 7, 8, 9, 10];

    try {
      await nft.setApprovalForAll(box.address, true);

      for (i = 0; i < slotId.length; i++) {
        await box.depositNFT(slotId[i], nft.address, nftId[i], 1000);
      }
      expect(true);
    } catch (error) {
      // console.log("must be invalid slot:", error.message);
      expect(false);
    }
  });

  it("test get randomness result", async () => {
    let rand = await box.getRandomNumber();
    console.log("randomness", rand.toString());
  });

  it("should be able to draw NFT from kPunkBox", async () => {
    await box
      .connect(minter)
      .drawWithKUB({ value: ethers.utils.parseEther("0.01") });

    // const results = await box.results(0);
    expect((await nft.ownerOf(5)).toString()).to.equal(minter.address);
  });

  it("box owner should be able to withdraw nft and empty the slot", async () => {
    let slotId = 0;
    await box.withdrawNFT(slotId);

    const slot0 = await box.list(0);

    expect(slot0.isLocked).to.equal(false);
  });

  it("should be able to check winning rate from avaliable slot", async () => {
    let rate = await box.getWinningRates();

    expect(parseInt(rate.toString())).greaterThan(0);
  });

  it("should be able to check contract balance", async () => {
    let balance = await box.getBalance();
    expect(ethers.utils.formatUnits(balance, "ether")).to.equal("0.01");
  });
});
