const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CodifaiEngine", function () {
  let signers;

  before('Create fixture loader', async () => {
    signers = await ethers.getSigners();
  })

  it("Should return pools information", async function () {
    const CodifaiEngine = await ethers.getContractFactory("CodifaiEngine");
    const codifaiEngine = await CodifaiEngine.deploy(signers[0].address);    
    await codifaiEngine.deployed();

    const TestToken = await ethers.getContractFactory("TestToken");
    const testToken = await TestToken.deploy("Codifai Test Token", "CTT", ethers.utils.parseEther("10000"));
    await testToken.deployed();

    console.log(codifaiEngine.address);
    console.log(testToken.address);
  });
});
