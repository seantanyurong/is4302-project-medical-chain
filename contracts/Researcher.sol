pragma solidity ^0.5.0;

contract Researcher {

    struct researcher {
        uint256 researcherId;
        address owner;
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
    }

    uint256 public numResearchers = 0;
    mapping(uint256 => researcher) public researchers;

    // function to create patient
    function create(string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob) public returns(uint256) {

        uint256 newResearcherId = numResearchers++;

        researcher memory newResearcher;
        newResearcher.researcherId = newResearcherId;
        newResearcher.owner = msg.sender;
        newResearcher.firstName = _firstName;
        newResearcher.lastName = _lastName;
        newResearcher.emailAddress = _emailAddress;
        newResearcher.dob = _dob;

        researchers[newResearcherId] = newResearcher;
        emit ResearcherAdded(newResearcher.owner);
        return newResearcherId;
    }


    /********* EVENTS *********/

    event ResearcherAdded(address researcherAddress);

    /********* MODIFIERS *********/

    modifier ownerOnly(uint256 researcherId) {
        require(researchers[researcherId].owner == tx.origin);
        _;
    }

    modifier validResearcherId(uint256 researcherId) {
        require(researcherId < numResearchers);
        _;
    }


    /********* FUNCTIONS *********/

    // Loop through existing senders to check if address is a sender
    function isSender(address owner) public view returns(bool) {
        for (uint i = 0; i < numResearchers; i++) {
            researcher storage temp = researchers[i];
            if (temp.owner == owner) {
                return true;
            }
        }

        return false;
    }
    

    /********* GETTERS & SETTERS *********/

    function getFirstName(uint256 researcherId) public view validResearcherId(researcherId) ownerOnly(researcherId) returns(string memory) {
        return researchers[researcherId].firstName;
    }

    function setFirstName(uint256 researcherId, string memory _firstName) public validResearcherId(researcherId) ownerOnly(researcherId)  {
        researchers[researcherId].firstName = _firstName;
    }

    function getLastName(uint256 researcherId) public view validResearcherId(researcherId) ownerOnly(researcherId) returns(string memory) {
        return researchers[researcherId].lastName;
    }

    function setLastName(uint256 researcherId, string memory _lastName) public validResearcherId(researcherId) ownerOnly(researcherId)  {
        researchers[researcherId].lastName = _lastName;
    }

    function getEmailAddress(uint256 researcherId) public view validResearcherId(researcherId) ownerOnly(researcherId) returns(string memory) {
        return researchers[researcherId].emailAddress;
    }

    function setEmailAddress(uint256 researcherId, string memory _emailAddress) public validResearcherId(researcherId) ownerOnly(researcherId) {
        researchers[researcherId].emailAddress = _emailAddress;
    }

    function getDob(uint256 researcherId) public view  validResearcherId(researcherId) ownerOnly(researcherId) returns(string memory) {
        return researchers[researcherId].dob;
    }

    function setDob(uint256 researcherId, string memory _dob) public validResearcherId(researcherId) ownerOnly(researcherId) {
        researchers[researcherId].dob = _dob;
    }

}