const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CodifaiEngine", function () {
  let signers;

  before('Create fixture loader', async () => {
    signers = await ethers.getSigners();
  })

  it("Should create engine and pools exactly.", async function () {
    const engineCreator = signers[0];
    const orgCustomer = signers[1];
    const normalCustomer = signers[2];

    const CodifaiEngine = await ethers.getContractFactory("CodifaiEngine");
    const codifaiEngine = await CodifaiEngine.deploy(engineCreator.address);    
    await codifaiEngine.deployed();

    const TestToken = await ethers.getContractFactory("TestToken");
    const testToken = await TestToken.connect(orgCustomer).deploy("Codifai Test Token", "CTT", 10000);
    await testToken.deployed();
    console.log("CodifaiEngine:", codifaiEngine.address);
    console.log("TestToken:", testToken.address);

    const balance = await testToken.balanceOf(orgCustomer.address);
    await testToken.connect(orgCustomer).approve(codifaiEngine.address, balance);

    let tokens = [testToken.address];
    let amounts = [balance];

    let _tx = await codifaiEngine.connect(orgCustomer).createCodifaiPool(tokens, amounts);
    let _receipt = await _tx.wait();
    let _events = _receipt.events.filter((x) => {return x.event == "CodifaiPoolCreated"});
    if (_events.length > 0) {
      const codifaiPoolAddr = _events[0].args[0];
      console.log("Created CodifaiPool:", codifaiPoolAddr);
    }
  });
});
