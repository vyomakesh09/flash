const hre = require("hardhat");

async function main() {
  // Get the contract factory
  const FlashLoan = await hre.ethers.getContractFactory("FlashLoan");

  // Deploy the contract
  // Replace with the appropriate Pool address for your network
  const POOL_ADDRESS = {
    mainnet: "0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2",
    polygon: "0x794a61358D6845594F94dc1DB02A252b5b4814aD",
  };

  const poolAddress = POOL_ADDRESS[hre.network.name] || POOL_ADDRESS.mainnet;
  
  const flashLoan = await FlashLoan.deploy(poolAddress);
  await flashLoan.deployed();

  console.log(`FlashLoan deployed to: ${flashLoan.address}`);
  console.log(`Using Pool address: ${poolAddress}`);

  // Wait for a few block confirmations
  await flashLoan.deployTransaction.wait(6);

  // Verify the contract on Etherscan
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    await hre.run("verify:verify", {
      address: flashLoan.address,
      constructorArguments: [poolAddress],
    });
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 