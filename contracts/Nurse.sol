pragma solidity ^0.5.0;

import "./EHR.sol";

contract Nurse {

    struct nurse {
        address owner;
        uint256 nurseId;
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
 
        mapping(uint256 => bool) patients;
        mapping(uint256 => bool) records;
    }

    uint256 public numNurses = 0;
    mapping(uint256 => nurse) public nurses;

    // function to create nurse
    function create(string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob) public returns(uint256) {

        uint256 newNurseId = numNurses++;

        nurse memory newNurse;
        newNurse.nurseId = newNurseId;
        newNurse.owner = msg.sender;
        newNurse.firstName = _firstName;
        newNurse.lastName = _lastName;
        newNurse.emailAddress = _emailAddress;
        newNurse.dob = _dob;

        nurses[newNurseId] = newNurse;
        emit NurseAdded(newNurse.owner);
        return newNurseId;
    }

    /********* EVENTS *********/

    event NurseAdded(address nurseAddress);

    /********* MODIFIERS *********/

    modifier ownerOnly(uint256 nurseId) {
        require(nurses[nurseId].owner == tx.origin);
        _;
    }

    modifier validNurseId(uint256 nurseId) {
        require(nurseId < numNurses);
        _;
    }


    /********* FUNCTIONS *********/

    function isSender(address owner) public view returns(bool) {
        for (uint i = 0; i < numNurses; i++) {
            nurse storage temp = nurses[i];
            if (temp.owner == owner) {
                return true;
            }
        }

        return false;
    }

    function isPatientInListOfPatients(uint256 patientId, address owner) public view returns(bool) {
        for (uint i = 0; i < numNurses; i++) {
            nurse storage temp = nurses[i];
            if (temp.owner == owner) {
                if (temp.patients[patientId] == true) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        return false;
    }


    /********* GETTERS & SETTERS *********/

    function getFirstName(uint256 nurseId) public view validNurseId(nurseId) ownerOnly(nurseId) returns(string memory) {
        return nurses[nurseId].firstName;
    }

    function setFirstName(uint256 nurseId, string memory _firstName) public validNurseId(nurseId) ownerOnly(nurseId) {
        nurses[nurseId].firstName = _firstName;
    }

    function getLastName(uint256 nurseId) public view validNurseId(nurseId) ownerOnly(nurseId) returns(string memory) {
        return nurses[nurseId].lastName;
    }

    function setLastName(uint256 nurseId, string memory _lastName) public validNurseId(nurseId) ownerOnly(nurseId) {
        nurses[nurseId].lastName = _lastName;
    }

    function getEmailAddress(uint256 nurseId) public view validNurseId(nurseId) ownerOnly(nurseId) returns(string memory) {
        return nurses[nurseId].emailAddress;
    }

    function setEmailAddress(uint256 nurseId, string memory _emailAddress) public validNurseId(nurseId) ownerOnly(nurseId) {
        nurses[nurseId].emailAddress = _emailAddress;
    }

    function getDob(uint256 nurseId) public view validNurseId(nurseId) ownerOnly(nurseId) returns(string memory) {
        return nurses[nurseId].dob;
    }

    function setDob(uint256 nurseId, string memory _dob) public validNurseId(nurseId) ownerOnly(nurseId) {
        nurses[nurseId].dob = _dob;
    }
}