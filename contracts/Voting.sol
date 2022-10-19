// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Voting{
    constructor(){
        admins[msg.sender]=true;
    }
    //Variable
    struct Voter{
        address voterAddress;
        int256 voterId;
        string voterName;
        bool registered;
        bool voted;
        Election election;
    }
    struct Candidate{
        string candidateName;
        string candidateDetails;
        bool exists;
        int voteCount;
        Position position;
    }
    struct Position{
        string name;
        string details;
        Election election;
        bool exists;
    }
    struct Election {
        string name;
        string details;
        State state;
        bool exists;
    }
    enum State {NotStarted,Running,Ended}

    uint public test = 4;

    //Mapping
    mapping (string => Election) Elections;
    mapping (string => Position) Positions;
    mapping (address => bool ) admins;
    mapping (string => Candidate) Candidates;
    mapping (address => Voter) Voters;

    
    //Modifiers
    modifier onlyAdmin() {
        require (admins[msg.sender] == true,"only Admin");
        _;
    }
    modifier registered(){
        require (Voters[msg.sender].registered==true,"Not Registered");_;
    }
    modifier notVoted(){
        require (Voters[msg.sender].voted==false,"Already Voted");_;
    }
    modifier positionExists (string memory name) {require (Positions[name].exists==true,"Position does not exists");_;}
    modifier candidateExists (string memory name) {require (Candidates[name].exists==true,"Candidate does not exists");_;}
    modifier electionExists (string memory name) {require (Elections[name].exists==true,"Election does not exists");_;}
    modifier electionNotStarted (string memory eName) {require(Elections[eName].state==State.NotStarted,"Started or Ended");_;}
    modifier electionRunning (string memory eName) {require(Elections[eName].state==State.Running,"Not Running");_;}
    modifier electionEnded (string memory eName) {require(Elections[eName].state==State.Ended,"Not Ended");_;}

    //Functions
    function addAdmin (address _address) public 
    onlyAdmin 
    {
        admins[_address]=true;
    }


    function checkAdmin () public view 
    returns(bool) 
    {
        return admins[msg.sender];
    }

    function addElection(string memory electionName, string memory electionDetails) public
    onlyAdmin
    {
        Elections[electionName].name = electionName;
        Elections[electionName].details = electionDetails;
        Elections[electionName].state = State.NotStarted;
        Elections[electionName].exists = true;
    }

    function addPosition(string memory positionName, string memory positionDetails, string memory electionName) public 
    onlyAdmin
    electionNotStarted(electionName)
    electionExists(electionName)
    {
        Positions[positionName].name = positionName;
        Positions[positionName].details = positionDetails;
        Positions[positionName].election = Elections[electionName]; 
        Positions[positionName].exists = true;
    }


    function addCandidate(string memory name, string memory details, string memory positionName) public 
    electionExists(Positions[positionName].election.name)
    electionNotStarted(Positions[positionName].election.name)
    positionExists(positionName)
    onlyAdmin
    {
        Candidates[name].candidateName=name;
        Candidates[name].candidateDetails=details;
        Candidates[name].position=Positions[positionName];
        Candidates[name].exists=true;
        Candidates[name].voteCount=0;
    }

    function getElection (string memory name) public view 
    returns (string memory electionName, string memory electionDetails, State electionState){
        electionName = Elections[name].name;
        electionDetails = Elections[name].details;
        electionState = Elections[name].state;
        return (electionName,electionDetails,electionState);
    }

    function getPosition (string memory name) public view 
    returns (string memory positionName, string memory positionDetails, string memory electionName ){
        positionName = Positions[name].name;
        positionDetails = Positions[name].details;
        electionName = Positions[name].election.name;
        return (positionName,positionDetails,electionName);
    }

    function getCandidates(string memory candidateName) public view 
    returns (string memory name,string memory details, bool exists, int voteCount,string memory position){
        name=Candidates[candidateName].candidateName;
        details=Candidates[candidateName].candidateDetails;
        exists=Candidates[candidateName].exists;
        voteCount = Candidates[candidateName].voteCount;
        position = Candidates[candidateName].position.name;
        return (name,details,exists,voteCount,position);
    }


    function addVoter(int256 voterId,string memory voterName, string memory electionName)public
    electionExists(electionName)
    electionNotStarted(electionName)
    {
        address _address = msg.sender;
        Voters[_address].voterId = voterId;
        Voters[_address].voterName = voterName;
        Voters[_address].election = Elections[electionName];
    }


    
    function verifyVoter(address _address) public
    onlyAdmin
    electionExists(Voters[_address].election.name)
    electionNotStarted(Voters[_address].election.name)
    {
        Voters[_address].registered=true;
        Voters[_address].voted=false;
    }



    function vote (string memory candidateName) public
    electionRunning(Candidates[candidateName].position.election.name) 
    registered
    notVoted 
    candidateExists(candidateName)
    returns(bool){
        
        Voters[msg.sender].voted=true;
        Candidates[candidateName].voteCount++;
        return true;
    }


    function getVoter() public view 
    returns (int256 voterId,bool vregistered,bool voted){
        voterId=Voters[msg.sender].voterId;
        vregistered=Voters[msg.sender].registered;
        voted=Voters[msg.sender].voted;
        return(voterId,vregistered,voted);
    }

    function startElection(string memory electionName) public
    onlyAdmin
    electionExists(electionName)
    electionNotStarted(electionName)
    {
        Elections[electionName].state = State.Running;
    }

    function endElection(string memory electionName) public
    onlyAdmin
    electionExists(electionName)
    electionRunning(electionName)
    {
        Elections[electionName].state = State.Ended;
    }
}