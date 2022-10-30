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

    const pos = "senator";
    const posDetails = "Represent a planet";

    const electionName = "senator-naboo";
    const electionDetails = "Selecting senator of Naboo";

    const candidateName = "Padme Amadala";
    const candidateDetails = "Princess of Naboo";

    const candidate1Name = "Jar Jar Binks";
    const candidate1Details = "Misa Jar Jar, Yusa?";

    const voterName = "Anakin Skywalker";

    it("Should create position", async function () {
        console.log(await voting.checkAdmin());

        await voting.createPosition(pos, posDetails);

        var res = await voting.getPosition(pos);
        // console.log(res);
        assert.equal(posDetails, res["details"]);
        var res = await voting.getAllPositions();
        console.log(res)
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

    it("Should create election", async function () {
        // need to create position first
        await voting.createPosition(pos, posDetails);
        await voting.createElection(electionName, electionDetails, pos);
    });

    it("Should request Candidancy", async function () {
        const [_, addr1] = await ethers.getSigners();
        await voting.createPosition(pos, posDetails);
        await voting.createElection(electionName, electionDetails, pos);
        await voting
            .connect(addr1)
            .requestCandidancy(candidateName, candidateDetails, electionName);
        res = await voting.getCandidate(addr1.address);
        console.log(res);
    });

    it("Should verify candidancy", async function() {
        const [_, addr1] = await ethers.getSigners();
        await voting.createPosition(pos, posDetails);
        await voting.createElection(electionName, electionDetails, pos);
        await voting
            .connect(addr1)
            .requestCandidancy(candidateName, candidateDetails, electionName);
        
        res = await voting.getAllUnVerifiedCandidates();
        console.log("before verification", res);
        res = await voting.getVerifiedCandidatesOfElection(electionName);
        console.log("before verification verified", res);
        await voting.verifyCandidancy(addr1.address, true, electionName)
        
        res = await voting.getAllUnVerifiedCandidates();
        console.log("after verification", res);
        res = await voting.getVerifiedCandidatesOfElection(electionName);
        console.log("after verification verified", res);
        // res = await voting.getCandidate(addr1.address);
        // console.log(res);
    });

    it("Should request voter, verify and vote", async function() {
        const [_, addr1, addr2] = await ethers.getSigners();
        await voting.connect(addr2).requestVoter(voterName);
        
        res = await voting.getVerifiedVoters();
        console.log("before verification ==== verified votors", res)
        res = await voting.getUnVerifiedVoters();
        console.log("before verification ==== unverified votors", res)

        await voting.verifyVoter(addr2.address, true);

        res = await voting.getVerifiedVoters();
        console.log("after verification ==== verified votors", res)
        res = await voting.getUnVerifiedVoters();
        console.log("after verification ==== unverified votors", res)

        await voting.createPosition(pos, posDetails);
        await voting.createElection(electionName, electionDetails, pos);
        await voting
            .connect(addr1)
            .requestCandidancy(candidateName, candidateDetails, electionName);
        
        await voting.verifyCandidancy(addr1.address, true, electionName)
        res = await voting.getCandidate(addr1.address);
        console.log(res)

        await voting.startElection(electionName);
        res = await voting.getVotes(electionName);
        // console.log(res);
        // vote before voting
        await voting.connect(addr2).vote(electionName, addr1.address);
        // await voting.connect(addr2).vote(electionName, addr1.address);
        await voting.endElection(electionName);
        // await voting.connect(addr2).vote(electionName, addr1.address);
        res = await voting.getVotes(electionName);
        // console.log(res);
    });

    it("Should create 2 candidates and count votes", async function() {
        const [_, candidate1, candidate2, voter] = await ethers.getSigners();
        await voting.connect(voter).requestVoter(voterName);
        res = await voting.getAllVoters();
        console.log("------", res)
        await voting.verifyVoter(voter.address, true);
        res = await voting.getAllVoters();
        console.log("======", res)


        await voting.createPosition(pos, posDetails);
        await voting.createElection(electionName, electionDetails, pos);
        await voting
            .connect(candidate1)
            .requestCandidancy(candidateName, candidateDetails, electionName);
        
        await voting.verifyCandidancy(candidate1.address, true, electionName)

        await voting
            .connect(candidate2)
            .requestCandidancy(candidate1Name, candidateDetails, electionName);
        
        await voting.verifyCandidancy(candidate2.address, true, electionName)

        await voting.startElection(electionName);
        // res = await voting.getVotes(electionName);
        // console.log(res);
        // vote before voting
        await voting.connect(voter).vote(electionName, candidate1.address);
        await voting.endElection(electionName);
        // res = await voting.getVotes(electionName);
        // console.log(res);
        res = await voting.getAllCandidates();
        console.log(res);
        // res = await voting.getAllElections();
        // console.log(res);
    })
});
