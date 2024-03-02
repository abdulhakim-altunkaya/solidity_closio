require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    bnb: {
      url: process.env.PROVIDER_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    fantom: {
      url: process.env.PROVIDER_URL_2,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    polygon: {
      url: process.env.PROVIDER_URL_3,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    fantomtest: {
      url: process.env.PROVIDER_URL_3,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  }
};
