require("dotenv").config({
  path: "./config.env",
});
require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNework: "localhost",
  networks: {
    bitkubTestnet: {
      url: "https://rpc-testnet.bitkubchain.io",
      accounts: [process.env.deployer],
    },
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};
