const { expect } = require("chai");
const { ethers } = require("hardhat");

let dev;
let creator;
let treasury;
let factory;

describe("Factory Contract Test", () => {
  before(async () => {
    [dev, creator, treasury] = await ethers.getSigners();

    const factoryContract = await ethers.getContractFactory("ChickaponFactory");
    factory = await factoryContract.deploy(dev.address, treasury.address);
    await factory.deployed();

    console.log("factory address", factory.address);
  });

  it("should be able to create new box", async () => {
    await factory
      .connect(creator)
      .createkPunkbox("new box", "NBOX", ethers.utils.parseEther("1"));

    const name = await factory.getBoxName(0);
    console.log("boxName", name.toString());
    expect(name.toString()).to.equal("new box");
  });

  it("shoud be able to create some more boxes", async () => {
    await factory
      .connect(creator)
      .createkPunkbox("new box1", "NBOX", ethers.utils.parseEther("1"));
    await factory
      .connect(creator)
      .createkPunkbox("new boxw", "NBOX", ethers.utils.parseEther("1"));
  });

  it("should be able to get box length", async () => {
    const len = await factory.getBoxCount();
    expect(len.toString()).to.equal("3");
  });
});
