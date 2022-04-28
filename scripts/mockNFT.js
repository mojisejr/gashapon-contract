const { ethers } = require("hardhat");
async function main() {
  const signer = await ethers.getSigner();
  const factory = await ethers.getContractFactory("NFT1");
  const nft = await factory.deploy();
  await nft.deployed();

  console.log("nft address: ", nft.address);

  await nft.connect(signer).mint();
  await nft.connect(signer).mint();
  await nft.connect(signer).mint();
  await nft.connect(signer).mint();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
