const { ether, ethers } = require("hardhat");
const { expect, assert } = require("chai");
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

    it("Should create position", async function () {
        console.log(await voting.checkAdmin());
        const pos = "chancellor";
        const details = "Represent a planet";
        await voting.createPosition(pos, details);

        var res = await voting.getPosition(pos);
        console.log(res);
        assert.equal(details, res["details"]);

        // await voting.createPosition(pos, "duplicate position")

        // it("Should not create same position", async function () {
        //     const pos = "chancellor";
        //     const details = "duplicate position";
        //     await voting.createPosition(pos, details);
        //     var res = await voting.getPosition(pos);
        //     console.log("new");
        //     console.log(res);
        // });
    });

});
