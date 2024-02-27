const hre = require("hardhat");
async function main() {
  const testWBNB = await hre.ethers.deployContract("TestWBNB", [1000000000]);
  await testWBNB.deployed();
  console.log(
    `TestWBNB deployed to address: ${testWBNB.address}`
  );
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});