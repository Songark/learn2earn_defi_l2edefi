const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CodifaiEngine", function () {
  let signers;
  let engineCreator;
  let courseCreator;
  let courseUser1;
  let courseUser2;
  let codifaiEngine;
  let testToken;

  before('Create fixture loader', async () => {
    signers = await ethers.getSigners();

    engineCreator = signers[0];
    courseCreator = signers[1];
    courseUser1 = signers[2];
    courseUser2 = signers[3];

    const CodifaiEngine = await ethers.getContractFactory("CodifaiEngine");
    codifaiEngine = await CodifaiEngine.deploy(engineCreator.address);    
    await codifaiEngine.deployed();

    const TestToken = await ethers.getContractFactory("TestToken");
    testToken = await TestToken.connect(courseCreator).deploy("Codifai Test Token", "CTT", 10000);
    await testToken.deployed();
    console.log("CodifaiEngine:", codifaiEngine.address);
    console.log("TestToken:", testToken.address);
  })

  async function showBalances() {
    console.log("Token Balances:");    
    let balance = await testToken.balanceOf(engineCreator.address);
    console.log("engineCreator:", ethers.utils.formatEther(balance));
    balance = await testToken.balanceOf(courseCreator.address);
    console.log("courseCreator:", ethers.utils.formatEther(balance));
    balance = await testToken.balanceOf(courseUser1.address);
    console.log("courseUser1:", ethers.utils.formatEther(balance));
    balance = await testToken.balanceOf(courseUser2.address);
    console.log("courseUser2:", ethers.utils.formatEther(balance), "\n");    
  }

  it("Should create engine and pools exactly.", async function () {
     
    await showBalances(testToken, engineCreator, courseCreator, courseUser1, courseUser2);

    const balance = await testToken.balanceOf(courseCreator.address);
    await testToken.connect(courseCreator).approve(codifaiEngine.address, balance);

    let tokens = [testToken.address];
    let amounts = [balance];

    let _tx = await codifaiEngine.connect(courseCreator).createCodifaiPool(tokens, amounts);
    let _receipt = await _tx.wait();
    let _events = _receipt.events.filter((x) => {return x.event == "CodifaiPoolCreated"});
    if (_events.length > 0) {
      const poolIndex = _events[0].args[0];
      console.log("Created CodifaiPool Index:", poolIndex.toString());

      await showBalances();

      amounts[0] = balance.div(10);
      await codifaiEngine.connect(courseCreator).setCodifaiPoolRewards(poolIndex, amounts);
      console.log("Set CodifaiPool Rewards:", ethers.utils.formatEther(amounts[0]));

      _tx = await codifaiEngine.connect(courseUser1).completeLearning(poolIndex);
      _receipt = await _tx.wait();
      _events = _receipt.events.filter((x) => {return x.event == "CodifaiCompletedCourse"});
      if (_events.length > 0) {
        await codifaiEngine.connect(courseUser1).claimRewards(poolIndex, courseUser1.address);

        await showBalances();
      }

      _tx = await codifaiEngine.connect(courseUser2).completeLearning(poolIndex);
      _receipt = await _tx.wait();
      _events = _receipt.events.filter((x) => {return x.event == "CodifaiCompletedCourse"});
      if (_events.length > 0) {
        await codifaiEngine.connect(courseUser2).claimRewards(poolIndex, courseUser1.address);

        await showBalances();
      }
    }
  });
});
