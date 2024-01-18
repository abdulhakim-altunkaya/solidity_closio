const hre = require("hardhat");
async function main() {
  const csol = await hre.ethers.deployContract("CSOL", [100000000]);
  await csol.deployed();
  console.log(
    `csol deployed to address: ${csol.address}`
  );
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
