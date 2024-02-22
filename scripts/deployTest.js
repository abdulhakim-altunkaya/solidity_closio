const hre = require("hardhat");
async function main() {
  const testweth = await hre.ethers.deployContract("TestWETH", [100000000]);
  await testweth.deployed();
  console.log(
    `testweth deployed to address: ${testweth.address}`
  );
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
