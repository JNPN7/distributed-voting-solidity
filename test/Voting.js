const { ether, ethers } = require("hardhat");
const { expect, assert } = require("chai");

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
});
