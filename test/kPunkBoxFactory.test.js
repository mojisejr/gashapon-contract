// const { expect } = require("chai");
// const { ethers } = require("hardhat");

// let owner;
// let minter;

// let factory;
// let box;

// describe("kPunkBoxFactory contract testing", () => {
//   before(async () => {
//     [owner, minter] = await ethers.getSigners();

//     let factoryFactory = await ethers.getContractFactory("kPunkBoxFactory");
//     factory = await factoryFactory.deploy();

//     console.log("deployed address: ", factory.address);
//   });

//   it("should be able to create new box", async () => {
//     await factory.createNewBox(
//       "kPunkGasha No 1.",
//       "KPUNK",
//       ethers.utils.parseEther("0.01")
//     );

//     const currentBoxId = await factory.getCurrentBoxId();

//     let { contractAddress } = await factory.boxes(1);

//     let boxFactory = await ethers.getContractFactory("kPunkBox");
//     box = boxFactory.attach(contractAddress);

//     expect(currentBoxId.toString()).to.equal("2");
//   });

//   it("check initial parameter of newly created box", async () => {
//     const Boxname = (await box.name()).toString();
//     const Boxsymbol = (await box.symbol()).toString();
//     const { name, symbol } = await factory.boxes(1);

//     expect(Boxname).to.equal(name);
//     expect(Boxsymbol).to.equal(symbol);
//   });
// });
