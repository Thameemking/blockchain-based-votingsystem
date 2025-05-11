// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityVoting {
    struct Identity {
        string name;
        uint256 age;
        string email;
        bool exists;
        bool hasVoted;
    }

    // identity registry
    mapping(address => Identity) public identities;

    // vote counts
    mapping(string => uint256) public votes;

    // admin (you)
    address public admin = 0x6Ba9ca419385D561fEB55a6dD72cbE007ea1B283;

    // candidates
    string[] public candidateList = ["Alice", "Bob", "Carol"];

    // events
    event IdentityRegistered(address indexed user, string name, uint256 age, string email);
    event IdentityUpdated(address indexed user, string name, uint256 age, string email);
    event VoteCast(address indexed voter, string candidate);

    constructor() {
        // admin and candidateList are already set above
    }

    // register a new identity
    function registerIdentity(
        string calldata _name,
        uint256 _age,
        string calldata _email
    ) external {
        require(!identities[msg.sender].exists, "Already registered");
        identities[msg.sender] = Identity(_name, _age, _email, true, false);
        emit IdentityRegistered(msg.sender, _name, _age, _email);
    }

    // update an existing identity
    function updateIdentity(
        string calldata _name,
        uint256 _age,
        string calldata _email
    ) external {
        require(identities[msg.sender].exists, "Not registered");
        identities[msg.sender].name  = _name;
        identities[msg.sender].age   = _age;
        identities[msg.sender].email = _email;
        emit IdentityUpdated(msg.sender, _name, _age, _email);
    }

    // cast a vote
    function castVote(string calldata _candidate) external {
        Identity storage id = identities[msg.sender];
        require(id.exists, "Not registered");
        require(!id.hasVoted, "Already voted");
        require(isValidCandidate(_candidate), "Invalid candidate");

        votes[_candidate] += 1;
        id.hasVoted = true;
        emit VoteCast(msg.sender, _candidate);
    }

    // helper to check valid candidate
    function isValidCandidate(string calldata _candidate) internal view returns (bool) {
        for (uint i = 0; i < candidateList.length; i++) {
            if (keccak256(bytes(candidateList[i])) == keccak256(bytes(_candidate))) {
                return true;
            }
        }
        return false;
    }

    // read helpers
    function getCandidates() external view returns (string[] memory) {
        return candidateList;
    }

    function getVotes(string calldata _candidate) external view returns (uint256) {
        return votes[_candidate];
    }

    // only admin can call
    function winner() external view returns (string memory) {
        require(msg.sender == admin, "Only admin");
        string memory top     = candidateList[0];
        uint256      topCount = votes[top];
        for (uint i = 1; i < candidateList.length; i++) {
            uint256 c = votes[candidateList[i]];
            if (c > topCount) {
                topCount = c;
                top      = candidateList[i];
            }
        }
        return top;
    }
}
