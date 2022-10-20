// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// Errors
error VotingNew__OnlyAdmin();
error VotingNew__NotVoter();
error VotingNew__NotVerifiedVoter();
error VotingNew__AlreadyVoted();
error VotingNew__NoPosition();
error VotingNew__NoCandidate();
error VotingNew__CandidateAlreadyExists();
error VotingNew__ElectionExists();
error VotingNew__ElectionNotExixts();
error VotingNew__ElectionNotStarted();
error VotingNew__ElectionNotRunning();
error VotingNew__ElectionNotEnded();

contract VotingNew {
    struct Voter {
        address _address;
        string name;
        bool exists;
        bool verified; // admin verifies
    }
    struct Position {
        string name;
        string details;
        address person;
        bool exists;
    }
    struct Candidate {
        address _address;
        string name;
        string details;
        bool verified; // admin verifies
        bool exists;
        Election election;
    }
    enum State {
        NotStarted,
        Running,
        Ended
    }
    struct Election {
        // uint256 id;
        string name;
        string details;
        Position position;
        State state;
        // mapping(address => bool) voted; // error why don't know
        address[] voted;
        bool exists;
        // starting time
        // ending time
    }

    // mapping
    mapping(string => Election) elections;
    mapping(string => Position) positions;
    mapping(address => bool) admins;
    mapping(address => Candidate) candidates;
    mapping(address => Voter) voters;

    // modifiers
    modifier onlyAdmin() {
        if (admins[msg.sender] == true) {
            revert VotingNew__OnlyAdmin();
        }
        _;
    }
    modifier isVoter() {
        if (voters[msg.sender].exists != true) {
            revert VotingNew__NotVoter();
        }
        if (voters[msg.sender].verified != true) {
            revert VotingNew__NotVerifiedVoter();
        }
        _;
    }
    modifier notVoted(string memory election) {
        // isVoter() {
        // if (elections[election].voted[msg.sender] == true) {
        //     revert VotingNew__AlreadyVoted();
        // }
        _;
    }
    modifier positionExists(string memory position) {
        if (positions[position].exists == true) {
            revert VotingNew__NoPosition();
        }
        _;
    }
    modifier candidateExists(address candidate) {//, string memory election) {
        if (
            candidates[candidate].exists == true //&&
            // keccak256(abi.encodePacked(candidates[candidate].election.name)) ==
            // keccak256(abi.encodePacked(election))
        ) {
            revert VotingNew__NoCandidate();
        }
        _;
    }
    modifier candidateNotExists(address candidate) {//, string memory election) {
        if (
            candidates[candidate].exists != true //&&
            // keccak256(abi.encodePacked(candidates[candidate].election.name)) !=
            // keccak256(abi.encodePacked(election))
        ) {
            revert VotingNew__CandidateAlreadyExists();
        }
        _;
    }
    modifier electionExists(string memory election) {
        if (elections[election].exists == true) {
            revert VotingNew__ElectionExists();
        }
        _;
    }
    // need another logic, logic doesn't make sense
    modifier electionStarted(string memory election) {
        if (elections[election].state != State.NotStarted) {
            revert VotingNew__ElectionNotStarted();
        }
        _;
    }
    modifier electionRunning(string memory election) {
        if (elections[election].state != State.Running) {
            revert VotingNew__ElectionNotRunning();
        }
        _;
    }
    modifier electionEnded(string memory election) {
        if (elections[election].state != State.Ended) {
            revert VotingNew__ElectionNotEnded();
        }
        _;
    }

    // Functions
    function addAdmin(address _address) public onlyAdmin {
        admins[_address] = true;
    }

    function createPostion(string memory name, string memory details)
        public
        onlyAdmin
    {
        positions[name].name = name;
        positions[name].details = details;
        positions[name].exists = true;
    }

    function createElection(
        string memory name,
        string memory details,
        string memory position
    ) public onlyAdmin positionExists(position) {
        elections[name].name = name;
        elections[name].details = details;
        elections[name].position = positions[position];
        elections[name].exists = true;
        elections[name].state = State.NotStarted;
        // elections[name] = new Election(
        //     name = name,
        //     details = details,
        //     position = positions[position],
        //     exists = true,
        //     state = State.NotStarted
        // );
    }

    function requestCandidancy(
        string memory name,
        string memory details,
        string memory election
    ) public electionExists(election) candidateNotExists(msg.sender) {
        candidates[msg.sender]._address = msg.sender;
        candidates[msg.sender].name = name;
        candidates[msg.sender].details = details;
        candidates[msg.sender].exists = true;
        candidates[msg.sender].verified = false;
        candidates[msg.sender].election = elections[election];
    }

    function verifyCandidancy(
        address _address, 
        bool isVerified
    ) public onlyAdmin {
        if (isVerified == true) {
            candidates[_address].verified = true;
            return;
        }
        delete candidates[_address];
    }

    function getElection(string memory name) public view returns (
        string memory details,
        State state
    ) {
        details = elections[name].details;
        state = elections[name].state;
        return (details, state);
    }

    function getPosition(string memory name) public view returns (
        string memory details,
        address person
    ) {
        details = positions[name].details;
        person = positions[name].person;
        return (details, person);
    }

    function getCandidates(address _address) public view returns (
        string memory name,
        string memory details,
        bool verfied,
        bool exists,
        string memory position
    ) {
        name = candidates[_address].name;
        details = candidates[_address].details;
        verfied = candidates[_address].verified;
        exists = candidates[_address].exists;
        position = candidates[_address].election.position.name;
        return(name, details, verfied, exists, position);
    }

    function requestVoter(
        string memory name
    ) public  {
        if (voters[msg.sender].exists == true) {
            revert("voter already exist");
        }
        voters[msg.sender]._address = msg.sender;
        voters[msg.sender].name = name;
        voters[msg.sender].exists = true;
        voters[msg.sender].verified = false;
    }

    function verifyVoter(
        address _address, 
        bool isVerified
    ) public onlyAdmin {
        if (isVerified == true) {
            voters[_address].verified = true;
            return;
        }
        delete voters[_address];
    }


}