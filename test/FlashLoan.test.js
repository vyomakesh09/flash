const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FlashLoan", function () {
  let flashLoan;
  let owner;
  let mockPool;
  let mockToken;

  beforeEach(async function () {
    // Deploy mock contracts
    const MockPool = await ethers.getContractFactory("MockPool");
    mockPool = await MockPool.deploy();
    await mockPool.deployed();

    const MockToken = await ethers.getContractFactory("MockERC20");
    mockToken = await MockToken.deploy("Mock Token", "MTK");
    await mockToken.deployed();

    // Deploy FlashLoan contract
    const FlashLoan = await ethers.getContractFactory("FlashLoan");
    [owner] = await ethers.getSigners();
    flashLoan = await FlashLoan.deploy(mockPool.address);
    await flashLoan.deployed();
  });

  describe("Constructor", function () {
    it("Should set the correct pool address", async function () {
      expect(await flashLoan.POOL()).to.equal(mockPool.address);
    });
  });

  describe("requestFlashLoan", function () {
    it("Should revert with invalid array lengths", async function () {
      await expect(
        flashLoan.requestFlashLoan(
          [mockToken.address],
          [],
          ethers.utils.formatBytes32String("")
        )
      ).to.be.revertedWithCustomError(flashLoan, "InvalidArrayLength");
    });

    it("Should emit FlashLoanRequested event", async function () {
      const amount = ethers.utils.parseEther("1");
      await expect(
        flashLoan.requestFlashLoan(
          [mockToken.address],
          [amount],
          ethers.utils.formatBytes32String("")
        )
      )
        .to.emit(flashLoan, "FlashLoanRequested")
        .withArgs([mockToken.address], [amount]);
    });
  });

  // Add more tests as needed
}); 