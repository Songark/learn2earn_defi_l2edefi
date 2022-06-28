const hre = require("hardhat");

async function main() {
    const [owner] = await ethers.getSigners();
    
    const CodifyEngine = await hre.ethers.getContractFactory("CodifyEngine");
    const codifyEngine = await CodifyEngine.deploy();

    console.log("Engine: ", codifyEngine.address);
    
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
