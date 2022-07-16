const { expect } = require("chai");
const { ethers } = require("hardhat");
// const { MerkleTree } = require("merkletreejs");
// const keccak256 = require("keccak256");
// const whitelist = require("../scripts/randomhash.json");

let box;
let nft;
let owner;
let minter;
let dev;

describe("gashapon contract testing", () => {
  before(async () => {
    [owner, minter, dev, treasury] = await ethers.getSigners();
    let nftFactory = await ethers.getContractFactory("NFT1");
    let boxFactory = await ethers.getContractFactory("LuckBox");
    let factoryFactory = await ethers.getContractFactory("kPunkBoxFactory");

    //Deploy and mint nft to owner;
    nft = await nftFactory.deploy();
    await nft.deployed();

    //mint some nfts
    for (let i = 1; i < 12; i++) {
      await nft.mint();
    }

    let factory = await factoryFactory.deploy(dev.address, treasury.address);
    await factory.deployed();

    box = await boxFactory.deploy(
      "kPunkBox No.1",
      "KPUNK",
      ethers.utils.parseEther("0.01"),
      factory.address
    );

    await box.deployed();

    console.log("deployed addresses:", {
      nft: nft.address,
      box: box.address,
      factory: factory.address,
    });
  });

  it("check box initial parameter", async () => {
    expect((await box.name()).toString()).to.equal("kPunkBox No.1");
    expect((await box.symbol()).toString()).to.equal("KPUNK");
    expect((await box.ticketPrice()).toString()).to.equal(
      ethers.utils.parseEther("0.01").toString()
    );
  });

  it("should be able to deposit nfts", async () => {
    const tokenIds = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    nft.setApprovalForAll(box.address, true);
    tokenIds.forEach(async (id, index) => {
      await box.depositNft(index, nft.address, id);
    });

    expect((await nft.balanceOf(box.address)).toString()).to.equal(
      String(tokenIds.length)
    );
  });

  it("should be able to withdraw one by one until box is empty (force draw [test])", async () => {
    //test
    const length = [8, 7, 6, 5, 4, 3, 2, 1, 0];

    await box.connect(minter).forceDraw(length[0]);
    await box.connect(minter).forceDraw(length[1]);
    await box.connect(minter).forceDraw(length[2]);
    await box.connect(minter).forceDraw(length[3]);
    await box.connect(minter).forceDraw(length[4]);
    await box.connect(minter).forceDraw(length[5]);
    await box.connect(minter).forceDraw(length[6]);
    await box.connect(minter).forceDraw(length[7]);
    await box.connect(minter).forceDraw(length[8]);

    const balance = await nft.balanceOf(minter.address);
    expect(balance.toString()).to.equal(String(length.length));
  });

  // it("should be able to stack nft", async () => {
  //   //extra nft
  //   const tokenIds = [10, 11];

  //   tokenIds.forEach(async (tokenId) => {
  //     await box.stackNft(nft.address, tokenId);
  //   });

  //   const balance = await nft.balanceOf(box.address);

  //   expect(balance.toString()).to.equal(String(tokenIds.length));
  // });

  it("should be able to pull stacked nft from reserve and replace empty slot", async () => {
    for (let i = 0; i < 11; i++) {
      await nft.mint();
    }

    const tokenIds = [12, 13, 14, 15, 16, 17, 18, 19, 20];
    const stackId = 21;

    //deposit 9 items
    tokenIds.forEach(async (tokenId, index) => {
      await box.depositNft(index, nft.address, tokenId);
    });

    //stack one
    await box.stackNft(nft.address, stackId);

    //try to draw
    await box.connect(minter).forceDraw(0);

    const nftInSlotCount = await box.getNFTinSlotCount();
    expect(nftInSlotCount.toString()).to.equal(String(tokenIds.length));
  });

  it("should be able to withdraw nft from box", async () => {
    //try to with draw nft at slot no. 0
    await box.withdrawNft(0);

    const list = await box.list(0);
    expect(list.locked).to.false;
  });

  it("should be able to draw (actual function)", async () => {
    const options = { value: ethers.utils.parseEther("0.01") };
    await box.connect(minter).draw(options);
  });
});
