pragma solidity ^0.5.0;

import "./EHR.sol";

contract Doctor {

    EHR ehrContract;

    constructor(EHR ehrAddress) public {
        ehrContract = ehrAddress;
  }

    struct doctor {
        address owner;
        uint256 doctorId;
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
 
        mapping(uint256 => bool) patients;
        mapping(uint256 => bool) records;
    }

    uint256 public numDoctors = 0;
    mapping(uint256 => doctor) public doctors;

    // function to create doctor
    function create(string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob) public returns(uint256) {

        uint256 newDoctorId = numDoctors++;

        doctor memory newDoctor;
        newDoctor.doctorId = newDoctorId;
        newDoctor.owner = msg.sender;
        newDoctor.firstName = _firstName;
        newDoctor.lastName = _lastName;
        newDoctor.emailAddress = _emailAddress;
        newDoctor.dob = _dob;

        doctors[newDoctorId] = newDoctor;
        emit DoctorAdded(newDoctor.owner);
        return newDoctorId;
    }


    /********* EVENTS *********/

    event DoctorAdded(address doctorAddress);
    event AddressDoesNotBelongToAnyDoctor();


    /********* MODIFIERS *********/


    modifier ownerOnly(uint256 doctorId) {
        require(doctors[doctorId].owner == tx.origin);
        _;
    }

    modifier validDoctorId(uint256 doctorId) {
        require(doctorId < numDoctors);
        _;
    }


    /********* FUNCTIONS *********/

    function isValidDoctorId(uint256 doctorId) public view returns (bool) {
        if (doctorId < numDoctors) {
            return true;
        } else {
            return false;
        }
    }

    function isSender(address owner) public view returns(bool) {
        for (uint i = 0; i < numDoctors; i++) {
            doctor storage temp = doctors[i];
            if (temp.owner == owner) {
                return true;
            }
        }

        return false;
    }

    function isPatientInListOfPatients(uint256 patientId, address owner) public view returns(bool) {
        for (uint i = 0; i < numDoctors; i++) {
            doctor storage temp = doctors[i];
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

    function getIsPatientRegistered(uint256 doctorId, uint256 patientId) public view returns (bool) {
        return doctors[doctorId].patients[patientId];
    }

    function registerPatient(uint256 doctorId, uint256 patientId) public {
        doctors[doctorId].patients[patientId] = true;
    }

    function unregisterPatient(uint256 doctorId, uint256 patientId) public {
        doctors[doctorId].patients[patientId] = false;
    }

    // get doctor's address from their id (used in medicalChain numberOfRecordByDoctor function)
    function getDoctorAddressFromDoctorId(uint256 doctorId) public view returns (address) {
        return doctors[doctorId].owner;
    }

    // get doctor's id from their address 
    function getDoctorIdFromDoctorAddress(address doctorAddress) public view returns (uint256) {
        for (uint i = 0; i < numDoctors; i++) {
            if (doctors[i].owner == doctorAddress) {
                return i;
            }
        }

        return uint256(-1);
    }

    // Doctor: View all records belonging to this patient
  // Returns all the recordIds
  function doctorViewAllRecords(address patientAddress, uint256 patientNoOfRecords) public view returns (uint256[] memory) {
    uint256[] memory patientRecordsId = new uint256[](patientNoOfRecords);
    uint256 indexTracker = 0;
    for (uint256 i = 0; i < ehrContract.numEHR(); i++) {
        // record belongs to patient calling it
        if (ehrContract.isRecordBelongToPatient(i, patientAddress)) {
          patientRecordsId[indexTracker] = i;
          indexTracker++;
        }
      }

      return patientRecordsId;
  }

    /********* GETTERS & SETTERS *********/

    function getFirstName(uint256 doctorId) public view validDoctorId(doctorId) ownerOnly(doctorId) returns(string memory) {
        return doctors[doctorId].firstName;
    }

    function setFirstName(uint256 doctorId, string memory _firstName) public validDoctorId(doctorId) ownerOnly(doctorId) {
        doctors[doctorId].firstName = _firstName;
    }

    function getLastName(uint256 doctorId) public view validDoctorId(doctorId) ownerOnly(doctorId) returns(string memory) {
        return doctors[doctorId].lastName;
    }

    function setLastName(uint256 doctorId, string memory _lastName) public validDoctorId(doctorId) ownerOnly(doctorId) {
        doctors[doctorId].lastName = _lastName;
    }

    function getEmailAddress(uint256 doctorId) public view validDoctorId(doctorId) ownerOnly(doctorId) returns(string memory) {
        return doctors[doctorId].emailAddress;
    }

    function setEmailAddress(uint256 doctorId, string memory _emailAddress) public validDoctorId(doctorId) ownerOnly(doctorId) {
        doctors[doctorId].emailAddress = _emailAddress;
    }

    function getDob(uint256 doctorId) public view validDoctorId(doctorId) ownerOnly(doctorId) returns(string memory) {
        return doctors[doctorId].dob;
    }

    function setDob(uint256 doctorId, string memory _dob) public validDoctorId(doctorId) ownerOnly(doctorId) {
        doctors[doctorId].dob = _dob;
    }

}