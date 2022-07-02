# Learn to Earn platform L2EDefi

This platform provides a learn to earn mechanism where learners can earn crypto upon successful completion of a learning module. 
Our client organizations create one or more modules, each of which contains one or more lessons which, in turn, each has an assessment. 
Assessments can be in the form of quizzes, code reviews, or other verifiable activities. 

A smart contract will hold tokens supplied by an organization and will, depending on how the org administrator configures it, deliver reward amounts and royalty amounts when called by the contract owner (us). We are assuming for now that this contract gets deployed to Gnosis Chain, for its favorable gas fees.

## Configuration
* Org comes to our website/platform and configures characteristics of the contract, including:
  - Contract address for the ERC-20 token(s) they intend on depositing to contract
  - Reward amount (e.g. 0.00001 of token) paid to the user/learner per module (e.g. quiz)
  - Royalty amount (e.g. 10% of reward amount, or 0.0000001 of token) paid to the content author per module by a user
* We will transfer 20% (configurable by us) of the tokens to our public address as a service fee
* We publish the 'child' contract with the above information hard-coded into it
* We capture the contract address and make it available via the org's admin panel on our site

## Post contract deployment
* Org deposits tokens to contract
* Org can add/remove public addresses of authorized administrators
* Org can withdraw the entirety of the amount remaining via multi-sig with us as co-party

## Award distribution
* A module will have one or more assessments contained within it. A successful assessment triggers our platform to call the smart contract to distribute the defined reward amount to the learner's public address. Since there are multiple assessments per module, and one reward amount per module, I am thinking the call to distribute will include the learner's public address and the percentage of the reward amount to be distributed. For example, if the contract is configured to deliver 0.2 XYZ tokens per module, and a module has 5 assessments, each successful assessment will deliver (0.2/5) or 0.04 XYZ tokens to the user.
* Same logic applies to the royalty amount distributed.

## Other considerations
* Allow the organization to define/deposit more than one token as a reward type. For example, some DAOs have a tradeable token and a reputational token, which they may wish to award.
* Allow the organization to add/remove addresses of authorized authors
* Provide multi-sig capability to authorize the publication of a new module
* Support NFTs as an award type

## Build, deploy and test
```shell
npx hardhat compile
npx hardhat clean
npx hardhat test
node scripts/sample-script.js
```
