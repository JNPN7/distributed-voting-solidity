const hre = require("hardhat");

async function main() {
    // const Voting = await hre.ethers.getContractFactory("Voting");
    // console.log("Deploying contract...");
    // const voting = await Voting.deploy();
    // console.log(`Deployed contract address: ${voting.address}`);
    const Voting_new = await hre.ethers.getContractFactory("VotingNew");
    console.log("Deploying contract...");
    const voting_new  = await Voting_new.deploy();
    console.log(`Deployed contract address: ${voting_new.address}`);
}

main().catch((error) => {
    console.log(error);
    process.exit(1);
});
