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
  let poolIndexs;

  before('Create fixture loader', async () => {
    signers = await ethers.getSigners();
    poolIndexs = [];

    /// set different users' wallet address
    engineCreator = signers[0];
    courseCreator = signers[1];
    courseUser1 = signers[2];
    courseUser2 = signers[3];

    /// deploy main engine: CodifaiEngine contract
    console.log("[Deploy CodifaiEngine]");    
    const CodifaiEngine = await ethers.getContractFactory("CodifaiEngine");
    codifaiEngine = await CodifaiEngine.deploy(engineCreator.address);    
    await codifaiEngine.deployed();
    console.log("\tCodifaiEngine:", codifaiEngine.address);

    /// deploy test token: TestToken contract
    console.log("[Deploy TestToken]");    
    const TestToken = await ethers.getContractFactory("TestToken");
    testToken = await TestToken.connect(courseCreator).deploy("Codifai Test Token", "CTT", 10000);
    await testToken.deployed();
    console.log("\tTestToken:", testToken.address);
  })

  /**
   * @dev display all users' balance for monitoring changes
   */
  async function showBalances() {
    console.log("[Token Balances]");    
    for (let i = 0; i < poolIndexs.length; i++) {
      const poolBalance = await codifaiEngine.getCodifaiPoolBalance(poolIndexs[i], testToken.address);
      console.log("\tpool", poolIndexs[i].toString(), ":", parseFloat(ethers.utils.formatEther(poolBalance)).toFixed(1));
    }
    let balance = await testToken.balanceOf(engineCreator.address);
    console.log("\tengineCreator:", ethers.utils.formatEther(balance));
    balance = await testToken.balanceOf(courseCreator.address);
    console.log("\tcourseCreator:", ethers.utils.formatEther(balance));
    balance = await testToken.balanceOf(courseUser1.address);
    console.log("\tcourseUser1:", ethers.utils.formatEther(balance));
    balance = await testToken.balanceOf(courseUser2.address);
    console.log("\tcourseUser2:", ethers.utils.formatEther(balance));    
  }

  /**
   * @dev test case for creating pool, completing course, claiming rewards
   */
  it("Should create pool, complete course, claim rewards exactly.", async function () {
     
    await showBalances(testToken, engineCreator, courseCreator, courseUser1, courseUser2);

    /// set allowance for transferFrom in engine contract
    console.log("[Approve token for creating pool]")
    const balance = await testToken.balanceOf(courseCreator.address);    
    await testToken.connect(courseCreator).approve(codifaiEngine.address, balance);
    console.log("\tSet Allowance:", ethers.utils.formatEther(balance))

    let tokens = [testToken.address];
    let amounts = [balance];

    /// create Pool with tokens and amounts array, _ex) one token and all balance
    console.log("[Create Pool for One Course]")
    let _tx = await codifaiEngine.connect(courseCreator).createCodifaiPool(tokens, amounts);
    let _receipt = await _tx.wait();
    let _events = _receipt.events.filter((x) => {return x.event == "CodifaiPoolCreated"});
    if (_events.length > 0) {
      /// wait the CodifaiPoolCreated event from smart contract and get pool index
      const poolIndex = _events[0].args[0];
      poolIndexs.push(poolIndex);
      console.log("\tCreated CodifaiPool Successfully, Index:", poolIndex.toString());

      await showBalances();

      /// set rewards for each tokens in created pool, _ex) all balance / 100 => rewards
      amounts[0] = balance.div(100);
      await codifaiEngine.connect(courseCreator).setCodifaiPoolRewards(poolIndex, amounts);
      console.log("[Set CodifaiPool Rewards]\n\t", ethers.utils.formatEther(amounts[0]));

      /// if user1 will complete the course, he can call completeLearning with index and special code 
      console.log("[Complete Course in the Pool]")
      _tx = await codifaiEngine.connect(courseUser1).completeLearning(poolIndex);
      _receipt = await _tx.wait();
      _events = _receipt.events.filter((x) => {return x.event == "CodifaiCompletedCourse"});
      if (_events.length > 0) {
        console.log("\tComplete course successfully, User:", courseUser1.address, ", Index", poolIndex.toString());

        /// if user1's complete course request is successed, he can claim rewards with token receiver's address
        console.log("[Claim Rewards]");
        await codifaiEngine.connect(courseUser1).claimRewards(poolIndex, courseUser1.address);
        console.log("\tRewards claimed successfully, To:", courseUser1.address);

        await showBalances();
      }

      /// another completion request from user2
      console.log("[Complete Course in the Pool]")
      _tx = await codifaiEngine.connect(courseUser2).completeLearning(poolIndex);
      _receipt = await _tx.wait();
      _events = _receipt.events.filter((x) => {return x.event == "CodifaiCompletedCourse"});
      if (_events.length > 0) {
        console.log("\tComplete course successfully, User:", courseUser2.address, ", Index", poolIndex.toString());

        /// user2 can claim rewards and send reward tokens to user2's wallet
        console.log("[Claim Rewards]");
        await codifaiEngine.connect(courseUser2).claimRewards(poolIndex, courseUser1.address);
        console.log("\tRewards claimed successfully, To:", courseUser1.address);

        await showBalances();
      }
    }
  });
});
