const { ether, ethers } = require("hardhat");
const { expect, assert } = require("chai");
const { assertHardhatInvariant } = require("hardhat/internal/core/errors");
// const [owner, addr1, addr2] = await ethers.getSigners();
describe("Voting", function () {
    let votingFactory, voting;
    this.beforeEach(async function () {
        votingFactory = await ethers.getContractFactory("Voting");
        voting = await votingFactory.deploy();
    });

    it("Should have test value 0 at start", async function () {
        const testVal = await voting.test();
        const expectedVal = "4";
        assert.equal(testVal.toString(), expectedVal);
    });

    it("Should create election", async function () {
        const name = "testing";
        const details = "details";

        console.log(await voting.checkAdmin());
        await voting.addElection(name, details);

        let res = await voting.getElection(name);
        console.log(res);
    });
});

describe("Voting_new", function () {
    let votingFactory, voting;
    this.beforeEach(async function () {
        votingFactory = await ethers.getContractFactory("VotingNew");
        voting = await votingFactory.deploy();
    });

    const pos = "senator"
    const posDetails = "Represent a planet";

    const electionName = "senator-naboo";
    const electionDetails =  "Selecting senator of Naboo";

    const candidateName = "Padme Amadala";
    const candidateDetails = "Princess of Naboo";

    it("Should create position", async function () {
        console.log(await voting.checkAdmin());

        await voting.createPosition(pos, posDetails);

        var res = await voting.getPosition(pos);
        console.log(res);
        assert.equal(posDetails, res["details"]);
    });

    // it("Should not create same position", async function () {
    //     await voting.createPosition(pos, posDetails);

    //     // Create duplicate position
    //     // Expect error
    //     // TODO! passing the test of exception
    //     await voting.createPosition(pos, posDetails);
    // });

    // it("Should not create position if not owner", async function () {
    //     const [owner, addr1] = await ethers.getSigners();

    //     // Expect error
    //     await voting.connect(addr1).createPosition(pos, posDetails);
    // });

    it("Should create election", async function() {
        // need to create position first
        await voting.createPosition(pos, posDetails);

        await voting.createElection(electionName, electionDetails, pos)
    });

    it("Should request Candidancy", async function(){
        await voting.createPosition(pos, posDetails);

        await voting.createElection(electionName, electionDetails, pos)

        await voting.requestCandidancy(candidateName, candidateDetails, electionName);
    });
});
