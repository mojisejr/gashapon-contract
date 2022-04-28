const { ethers } = require("hardhat");

async function main() {
  const kPunkFactory = await ethers.getContractFactory("kPunkBoxFactory");
  const kpunk = await kPunkFactory.deploy();

  console.log("factory address: ", kpunk.address);
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
