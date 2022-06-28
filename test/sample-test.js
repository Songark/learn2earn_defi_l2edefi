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

    console.log(codifaiEngine.address);
  });
});
