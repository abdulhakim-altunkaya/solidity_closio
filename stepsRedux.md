1) npm install redux
2) npm install react-redux
3) npm install @reduxjs/toolkit
4) Create a "state" folder inside the "src"


20) 

Create your contracts
change deploy.js to something like this:


npm install hardhat "ethers@^5.7.2" dotenv "@openzeppelin/contracts"

npm install "@nomicfoundation/hardhat-toolbox@^2.0.2" "@nomiclabs/hardhat-ethers@^2.0.0" "@openzeppelin/contracts" "@chainlink/contracts" "@nomicfoundation/hardhat-network-helpers@^1.0.0" "@nomicfoundation/hardhat-chai-matchers@^1.0.0" "@nomicfoundation/hardhat-verify" --legacy-peer-deps

npm install "@nomiclabs/hardhat-etherscan@^3.0.0" "@types/mocha@>=9.1.0" "@typechain/ethers-v5@^10.1.0" "@typechain/hardhat@^6.1.2" "hardhat-gas-reporter@^1.0.8" "solidity-coverage@^0.8.1" "ts-node@>=8.0.0" "typechain@^8.1.0" "typescript@>=4.5.0" --legacy-peer-deps

npm init -y
npx hardhat init
npx hardhat compile
npx hardhat run --network mumbai scripts/deploy.js
npx hardhat flatten > Flattened.sol


*****Lock.sol*****
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.9;
contract Lock {
    uint public unlocktime = 1;
    constructor(uint _unlockTime) {
        unlocktime = _unlockTime;
    }
}

*****deploy.js******
const hre = require("hardhat");
async function main() {
  const lock = await hre.ethers.deployContract("Lock", [1000000]);
  //await lock.waitForDeployment();
  await lock.deployed();
  console.log(
    `Lock deployed to address: ${lock.address}`
  );
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


*****.env******
PROVIDER_URL=`https://rpc.ankr.com/polygon_mumbai`
PRIVATE_KEY="0969d8ec0d2c3a961ffaaff06aFWEFWEF9e303c90bc83f24213"



****hardhat.config.js****
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
module.exports = {
  solidity: "0.8.9",
  networks: {
    mumbai: {
      url: process.env.PROVIDER_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    }
  }
};

