// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// Errors
error VotingNew__OnlyAdmin();
error VotingNew__NotVoter();
error VotingNew__NotVerifiedVoter();
error VotingNew__AlreadyVoted();
error VotingNew__NoPosition();
error VotingNew__PositionAlreadyExists();
error VotingNew__NoCandidate();
error VotingNew__CandidateAlreadyExists();
error VotingNew__UnverifiedCandidate();
error VotingNew__ElectionExists();
error VotingNew__ElectionNotExists();
error VotingNew__ElectionNotExixts();
error VotingNew__ElectionNotStarted();
error VotingNew__ElectionNotRunning();
error VotingNew__ElectionNotEnded();

contract VotingNew {
    constructor() {
        admins[msg.sender] = true;
    }

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
        mapping(string => bool) verified; // admin verifies
        bool exists;
        Election[] election;
        mapping(string => uint256) voteCount;
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
        address[] candidates;
        // mapping (string => uint256) voteCount;
        // starting time
        // ending time
    }

    // mapping
    mapping(string => Election) elections;
    mapping(string => Position) positions;
    mapping(address => bool) admins;
    mapping(address => Candidate) candidates;
    mapping(address => Voter) voters;

    // lists
    string[] public electionsList;
    string[] public positionsList;
    address[] public candidateList;
    address[] votersList;

    // modifiers
    modifier onlyAdmin() {
        if (admins[msg.sender] != true) {
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
    // modifier notVoted(string memory election) {
    //     // isVoter() {
    //     // if (elections[election].voted[msg.sender] == true) {
    //     //     revert VotingNew__AlreadyVoted();
    //     // }
    //     _;
    // }
    modifier positionExists(string memory position) {
        if (positions[position].exists != true) {
            revert VotingNew__NoPosition();
        }
        _;
    }
    modifier positionNotExists(string memory position) {
        if (positions[position].exists == true) {
            revert VotingNew__PositionAlreadyExists();
        }
        _;
    }
    modifier candidateExists(address candidate, string memory election) {
        // if (
        //     candidates[candidate].exists != true &&
        //     keccak256(abi.encodePacked(candidates[candidate].election.name)) !=
        //     keccak256(abi.encodePacked(election))
        // ) {
        //     revert VotingNew__NoCandidate();
        // }
        if (candidates[candidate].exists != true)
            revert VotingNew__NoCandidate();
        for (uint256 i; i < candidates[candidate].election.length; i++) {
            if (
                keccak256(
                    abi.encodePacked(candidates[candidate].election[i].name)
                ) != keccak256(abi.encodePacked(election))
            ) {
                revert VotingNew__NoCandidate();
            }
        }
        _;
    }
    modifier isCandidateVerified(address candidate, string memory election) {
        if (candidates[candidate].verified[election] != true) {
            revert VotingNew__UnverifiedCandidate();
        }
        _;
    }
    modifier candidateNotExists(address candidate, string memory election) {
        // if (
        //     candidates[candidate].exists == true &&
        //     keccak256(abi.encodePacked(candidates[candidate].election.name)) ==
        //     keccak256(abi.encodePacked(election))
        // ) {
        //     revert VotingNew__CandidateAlreadyExists();
        // }
        if (candidates[candidate].exists == true)
            revert VotingNew__NoCandidate();
        for (uint256 i; i < candidates[candidate].election.length; i++) {
            if (
                keccak256(
                    abi.encodePacked(candidates[candidate].election[i].name)
                ) == keccak256(abi.encodePacked(election))
            ) {
                revert VotingNew__NoCandidate();
            }
        }
        _;
    }
    modifier electionExists(string memory election) {
        if (elections[election].exists != true) {
            revert VotingNew__ElectionNotExists();
        }
        _;
    }
    modifier electionNotExists(string memory election) {
        if (elections[election].exists == true) {
            revert VotingNew__ElectionExists();
        }
        _;
    }
    // need another logic, logic doesn't make sense
    // modifier electionStarted(string memory election) {
    //     if (elections[election].state != State.NotStarted) {
    //         revert VotingNew__ElectionNotStarted();
    //     }
    //     _;
    // }
    modifier electionRunning(string memory election) {
        if (elections[election].state != State.Running) {
            revert VotingNew__ElectionNotRunning();
        }
        _;
    }
    // modifier electionEnded(string memory election) {
    //     if (elections[election].state != State.Ended) {
    //         revert VotingNew__ElectionNotEnded();
    //     }
    //     _;
    // }

    // Functions
    // function addAdmin(address _address) public onlyAdmin {
    //     admins[_address] = true;
    // }

    function checkAdmin() public view returns (bool) {
        return admins[msg.sender];
    }

    function createPosition(string memory name, string memory details)
        public
        onlyAdmin
        positionNotExists(name)
    {
        positions[name].name = name;
        positions[name].details = details;
        positions[name].exists = true;
        positionsList.push(name);
    }

    function createElection(
        string memory name,
        string memory details,
        string memory position
    ) public onlyAdmin positionExists(position) electionNotExists(name) {
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
        electionsList.push(name);
    }

    function requestCandidancy(
        string memory name,
        string memory details,
        string memory election
    ) public electionExists(election) candidateNotExists(msg.sender, election) {
        candidates[msg.sender]._address = msg.sender;
        candidates[msg.sender].name = name;
        candidates[msg.sender].details = details;
        candidates[msg.sender].exists = true;
        candidates[msg.sender].election.push(elections[election]);

        candidateList.push(msg.sender);
    }

    function verifyCandidancy(
        address _address,
        bool isVerified,
        string memory election
    )
        public
        onlyAdmin
        electionExists(election)
        candidateExists(_address, election)
    {
        if (isVerified == true) {
            candidates[_address].verified[election] = true;
            elections[election].candidates.push(_address);
            return;
        }
        delete candidates[_address];
        // TODO! need to remove candidate form list
    }

    function getElection(string memory name)
        public
        view
        returns (string memory details, State state)
    {
        details = elections[name].details;
        state = elections[name].state;
        return (details, state);
    }

    function getAllElections() public view returns (string[] memory) {
        return electionsList;
    }

    function getPosition(string memory name)
        public
        view
        returns (
            string memory details,
            address person,
            bool exists
        )
    {
        details = positions[name].details;
        person = positions[name].person;
        exists = positions[name].exists;
        return (details, person, exists);
    }

    function getAllPositions() public view returns (string[] memory) {
        return positionsList;
    }

    function getCandidate(address _address)
        public
        view
        returns (
            string memory name,
            string memory details,
            Election[] memory election,
            bool[] memory verified
            // string memory position
        )
    {
        name = candidates[_address].name;
        details = candidates[_address].details;
        // verfied = candidates[_address].verified;
        election = candidates[_address].election;
        verified = new bool[](election.length);
        for (uint256 i; i< election.length; i++){
           verified[i] = candidates[_address].verified[election[i].name];
        }
        // position = candidates[_address].election.position.name;
        return (name, details, election, verified); //, position);
    }

    function getAllCandidates()
        public
        view
        returns (
            address[] memory allCandidatesAddress,
            string[] memory allCandidatesName
        )
    {
        allCandidatesAddress = candidateList;
        allCandidatesName = new string[](allCandidatesAddress.length);
        for (uint256 i; i < allCandidatesAddress.length; i++) {
            allCandidatesName[i] = candidates[allCandidatesAddress[i]].name;
        }
        return (allCandidatesAddress, allCandidatesName);
    }

    function getVerifiedCandidatesOfElection(string memory election)
        public
        view
        electionExists(election)
        returns (
            address[] memory candidatesAddress,
            string[] memory candidateName
        )
    {
        candidatesAddress = elections[election].candidates;
        candidateName = new string[](candidatesAddress.length);
        for (uint256 i; i < candidatesAddress.length; i++) {
            candidateName[i] = candidates[candidatesAddress[i]].name;
        }
        return (candidatesAddress, candidateName);
    }

    function getAllUnVerifiedCandidates()
        public
        view
        returns (
            address[] memory candidateAddress,
            string[] memory candidateName
        )
    {
        candidateAddress = new address[](candidateList.length);
        candidateName = new string[](candidateList.length);
        uint256 l = 0;
        for (uint256 i; i < candidateList.length; i++) {
            // Candidate memory candidate = candidates[candidateList[i]];
            for (uint256 j; j < candidates[candidateList[i]].election.length; j++) {
                if (candidates[candidateList[i]].verified[candidates[candidateList[i]].election[j].name] != true) {
                    candidateAddress[l] = candidates[candidateList[i]]._address;
                    candidateName[l++] = candidates[candidateList[i]].name;
                    break;
                }
            }
        }
        return (candidateAddress, candidateName);
    }

    // function getIsCandidateVerified(address _address, string memory election)
    //     public
    //     view
    //     returns (bool)
    // {
    //     return candidates[_address].verified[election];
    // }

    function requestVoter(string memory name) public {
        if (voters[msg.sender].exists == true) {
            revert("voter already exist");
        }
        voters[msg.sender]._address = msg.sender;
        voters[msg.sender].name = name;
        voters[msg.sender].exists = true;
        voters[msg.sender].verified = false;

        votersList.push(msg.sender);
    }

    function verifyVoter(address _address, bool isVerified) public onlyAdmin {
        if (isVerified == true) {
            voters[_address].verified = true;
            return;
        }
        delete voters[_address];
        // TODO! need to remove voters form list
    }

    function getAllVoters() public view onlyAdmin returns (address[] memory) {
        return votersList;
    }

    function getVerifiedVoters()
        public
        view
        onlyAdmin
        returns (address[] memory verifiedVoters)
    {
        verifiedVoters = new address[](votersList.length);
        uint256 l = 0;
        for (uint256 i; i < votersList.length; i++) {
            if (voters[votersList[i]].verified == true) {
                verifiedVoters[l++] = votersList[i];
            }
        }
        return (verifiedVoters);
    }

    function getUnVerifiedVoters()
        public
        view
        onlyAdmin
        returns (address[] memory unVerifiedVoters)
    {
        unVerifiedVoters = new address[](votersList.length);
        uint256 l = 0;
        for (uint256 i; i < votersList.length; i++) {
            if (voters[votersList[i]].verified != true) {
                unVerifiedVoters[l++] = votersList[i];
            }
        }
        return (unVerifiedVoters);
    }

    // function getUnVerifiedVoters();

    function getVoter(address _address) public view returns (
        Voter memory
    ) {
        return(voters[_address]);
    }

    function vote(string memory election, address candidate)
        public
        isVoter
        electionExists(election)
        electionRunning(election)
        candidateExists(candidate, election)
        isCandidateVerified(candidate, election)
    {
        // check if already voted
        for (uint256 i; i < elections[election].voted.length; i++) {
            address addr = elections[election].voted[i];
            if (addr == msg.sender) revert("You have already voted");
        }
        elections[election].voted.push(msg.sender);
        candidates[candidate].voteCount[election] += 1;
    }

    function getVotes(string memory election)
        public
        view
        electionExists(election)
        returns (
            address[] memory candidateAddr,
            string[] memory candidateName,
            uint256[] memory voteCount
        )
    {
        // candidateAddr = new address[elections[election].candidates.length];
        address[] memory _address = elections[election].candidates;
        candidateAddr = new address[](_address.length);
        candidateName = new string[](_address.length);
        voteCount = new uint256[](_address.length);
        for (uint256 i; i < _address.length; i++) {
            candidateAddr[i] = _address[i];
            candidateName[i] = candidates[_address[i]].name;
            voteCount[i] = candidates[_address[i]].voteCount[election];
        }
        return (candidateAddr, candidateName, voteCount);
    }

    // TODO! Need to use time
    // kamchlauu
    function startElection(string memory election)
        public
        onlyAdmin
        electionExists(election)
    {
        if (elections[election].state == State.Running) {
            revert("election already running");
        }
        if (elections[election].state == State.Ended) {
            revert("election already ended");
        }
        elections[election].state = State.Running;
    }

    function endElection(string memory election)
        public
        onlyAdmin
        electionExists(election)
    {
        if (elections[election].state == State.NotStarted) {
            revert("election not started");
        }
        if (elections[election].state == State.Ended) {
            revert("election already ended");
        }
        elections[election].state = State.Ended;
    }
}
