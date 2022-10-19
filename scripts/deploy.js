const hre = require("hardhat");

async function main() {
    const Voting = await hre.ethers.getContractFactory("Voting");
    console.log("Deploying contract...");
    const voting = await Voting.deploy();
    console.log(`Deployed contract address: ${voting.address}`);
}

main().catch((error) => {
    console.lot(error);
    process.exit(1);
});
