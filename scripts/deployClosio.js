const hre = require("hardhat");
async function main() {
  const closio = await hre.ethers.deployContract("Closio");
  //await lock.waitForDeployment();
  await closio.deployed();
  console.log(
    `closio deployed address: ${closio.address}`
  );
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

