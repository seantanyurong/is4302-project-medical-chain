pragma solidity ^0.5.0;

import "./EHR.sol";

contract Patient {

    EHR ehrContract;

    constructor(EHR ehrAddress) public {
        ehrContract = ehrAddress;
  }

    struct patient {
        uint256 patientId;
        address owner;
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
        bool approvedResearcher;
        mapping(address => bool) approvedDoctors;
        mapping(address => bool) approvedNurses;
        mapping(uint256 => bool) records;
        uint256 recordsCount;
        uint256 acknowledgedRecordsCount;
        address secondaryUser;
    }

    uint256 public numPatients = 0;
    mapping(uint256 => patient) public patients;

    // function to create patient
    function create(string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob, bool _approvedResearcher, address _secondaryUser) isPatientAlreadyRegistered(msg.sender) public returns(uint256) {

        emit testTrigger();

        uint256 newPatientId = numPatients++;

        patient storage newPatient = patients[newPatientId];
        newPatient.patientId = newPatientId;
        newPatient.owner = msg.sender;
        newPatient.firstName = _firstName;
        newPatient.lastName = _lastName;
        newPatient.emailAddress = _emailAddress;
        newPatient.dob = _dob;
        newPatient.approvedResearcher = _approvedResearcher;
        newPatient.recordsCount = 0;
        newPatient.acknowledgedRecordsCount = 0;
        newPatient.secondaryUser = _secondaryUser;

        emit PatientAdded(newPatient.owner);
        return newPatientId;
    }

    /********* EVENTS *********/

    event AddressDoesNotBelongToAnyPatient();
    event PatientAdded(address patientAddress);
    event GivingDoctorAccess();
    event printValue(uint256 a);
    event testTrigger();

    /********* MODIFIERS *********/

    modifier ownerOnly(uint256 patientId) {
        require(patients[patientId].owner == tx.origin, "Current user is not the intended patient!");
        _;
    }

    modifier validPatientId(uint256 patientId) {
        require(patientId < numPatients, "Invalid patient Id!");
        _;
    }

    modifier isApprovedDoctorOrNurse(uint256 patientId, address practitionerAddress) {
        require(isApprovedDoctor(patientId, practitionerAddress) == true || isApprovedNurse(patientId, practitionerAddress) == true, "Practitioner is not in patient's approved list");
        _;
    }

    modifier isPatientAlreadyRegistered(address patientAddress) {
        require(getPatientIdFromPatientAddress(patientAddress) == uint256(-1), "Patient already registered!");
        _;
    }

    modifier isSecondaryUserRegisteredPatient(address patientAddress) {
        require(getPatientIdFromPatientAddress(patientAddress) != uint256(-1) || patientAddress == address(0), "Secondary user not registered!");
        _;
    }

    /********* FUNCTIONS *********/

    function isValidPatientId(uint256 patientId) public view returns (bool) {
        if (patientId < numPatients) {
            return true;
        } else {
            return false;
        }
    }

    function isApprovedDoctor(uint256 patientId, address doctorAddress) public view returns (bool) {
        return patients[patientId].approvedDoctors[doctorAddress];
    }

    function isApprovedNurse(uint256 patientId, address nurseAddress) public view returns (bool) {
        return patients[patientId].approvedNurses[nurseAddress];
    }

    // Loop through existing senders to check if address is a sender
    function isSender(address owner) public view returns(bool) {
        for (uint i = 0; i < numPatients; i++) {
            // patient storage temp = patients[i];
            if (patients[i].owner == owner) {
                return true;
            }
        }

        return false;
    }

    // Populate this logic here
    function getResearchPatients() public view returns (uint256[] memory) {

        uint256 size = 0;

        // Get size since array size not mutable
        for (uint i = 0; i < numPatients; i++) {
            if (patients[i].approvedResearcher) {
                size++;
            }
        }

        uint256[] memory result = new uint256[](size);
        uint256 count = 0;

        // Loop through patients and feed approved into array
        for (uint i = 0; i < numPatients; i++) {
            if (patients[i].approvedResearcher) {
                result[count] = i;
                count++;
            }
        }

        return result;
    }

    // Patient verify record
    function signOffRecord(uint256 patientId, uint256 recordId) public {
        patients[patientId].acknowledgedRecordsCount++;
        ehrContract.patientSignOff(recordId);
    }

    // get patient's id from their address (used in medicalChain patientAcknowledgeRecord function)
    function getPatientIdFromPatientAddress(address patientAddress) public view returns (uint256) {
        for (uint i = 0; i < numPatients; i++) {
            if (patients[i].owner == patientAddress) {
                return i;
            }
        }
        return uint256(-1);
    }

    function viewAllRecords(uint256 patientId) public view returns (uint256[] memory) {
        uint256[] memory patientRecordsId = new uint256[](getRecordsCount(patientId));
        uint256 indexTracker = 0;
        address patientAddress = getPatientAddress(patientId);
        for (uint256 i = 0; i < ehrContract.numEHR(); i++) {
            if (ehrContract.isRecordBelongToPatient(i, patientAddress)) {
                patientRecordsId[indexTracker] = i;
                indexTracker++;
            }
        }

    return patientRecordsId;
    }

    // Patient: View all records (acknowledged and not acknowledged)
  function viewAllAcknowledgedRecords(uint256 patientId) public view returns (uint256[] memory) {
    uint256[] memory patientAcknowledgedRecordsId = new uint256[](getAcknowledgedRecordsCount(patientId));
    uint256 indexTracker = 0;
    for (uint256 i = 0; i < ehrContract.numEHR(); i++) {
      // record belongs to patient calling it AND whether the record is acknowledged
      if (ehrContract.isRecordBelongToPatient(i, msg.sender) && isRecordAcknowledged(patientId, i)) {
        patientAcknowledgedRecordsId[indexTracker] = i;
        indexTracker++;
      }
    }

    return patientAcknowledgedRecordsId;
  }

  // Patient: View all records issued by certain doctor
  function viewRecordsByDoctor(uint256 patientId, address doctorAddress) public view returns (uint256[] memory) {
    uint256[] memory patientRecordsId = viewAllRecords(patientId);
    uint256 noOfPatientRecords = getRecordsCount(patientId);
    uint256[] memory patientRecordsIdFiltered = new uint256[](numberOfRecordByDoctor(patientId, doctorAddress));
    uint256 indexTracker = 0;
    for (uint256 i = 0; i < noOfPatientRecords; i++) {
      if (ehrContract.doesRecordMatchDoctorAddress(patientRecordsId[i], doctorAddress)) {
        patientRecordsIdFiltered[indexTracker] = patientRecordsId[i];
        indexTracker++;
      }
    }

      return patientRecordsIdFiltered;
  }

    // Patient: Helper function to check how many records fulfilling the given doctor id
  function numberOfRecordByDoctor(uint256 patientId, address doctorAddress) public view returns(uint256) { // change on what you need to return
    uint256[] memory patientRecordsId = viewAllRecords(patientId);
    uint256 noOfPatientRecords = getRecordsCount(patientId);
    uint256 noOfRecordsByDoctorId = 0;
    for (uint256 i = 0; i < noOfPatientRecords; i++) {
      if (ehrContract.doesRecordMatchDoctorAddress(patientRecordsId[i], doctorAddress)) {
        noOfRecordsByDoctorId++;
      }
    }

    return noOfRecordsByDoctorId;
}

    // Patient: Filter records by record type
  function viewRecordsByRecordType(uint256 patientId, EHR.RecordType recordType) public view returns (uint256[] memory) {
    uint256[] memory patientRecordsId = viewAllRecords(patientId);
    uint256 noOfPatientRecords = getRecordsCount(patientId);
    uint256[] memory patientRecordsIdFiltered = new uint256[](numberOfRecordType(patientId, recordType));
    uint256 indexTracker = 0;
    for (uint256 i = 0; i < noOfPatientRecords; i++) {
      if (ehrContract.doesRecordMatchRecordType(patientRecordsId[i], recordType)) {
        patientRecordsIdFiltered[indexTracker] = patientRecordsId[i];
        indexTracker++;
      }
    }

    return patientRecordsIdFiltered;
  }

    // Patient: Helper function to check how many records fulfilling the given record type for a patient
  function numberOfRecordType(uint256 patientId, EHR.RecordType recordType) public view returns(uint256) { // change on what you need to return
    uint256[] memory patientRecordsId = viewAllRecords(patientId);
    uint256 noOfPatientRecords = getRecordsCount(patientId);
    uint256 noOfRecordsMatchingRecordType = 0;
    for (uint256 i = 0; i < noOfPatientRecords; i++) {
      uint256 currentRecordId = patientRecordsId[i];
      if (ehrContract.doesRecordMatchRecordType(currentRecordId, recordType)) {
        noOfRecordsMatchingRecordType++;
      }
    }

    return noOfRecordsMatchingRecordType;
}


    // checked the record is acknowledged by patient
    function isRecordAcknowledged(uint256 patientId, uint256 recordId) public view validPatientId(patientId) ownerOnly(patientId) returns(bool) {
        return patients[patientId].records[recordId];
    }

    function giveDoctorAccess(uint256 patientId, address doctorAddress) public {
        patients[patientId].approvedDoctors[doctorAddress] = true;
    }

    function removeDoctorAccess(uint256 patientId, address doctorAddress) public {
        patients[patientId].approvedDoctors[doctorAddress] = false;
    }

    function giveNurseAccess(uint256 patientId, address nurseAddress) public {
        patients[patientId].approvedNurses[nurseAddress] = true;
    }

    function removeNurseAccess(uint256 patientId, address nurseAddress) public {
        patients[patientId].approvedNurses[nurseAddress] = false;
    }

    function addEHR(uint256 patientId, uint256 recordId) public validPatientId(patientId) {
        patients[patientId].records[recordId] = true;
        patients[patientId].recordsCount++;
    }

    function removeEHR(uint256 patientId, uint256 recordId) public validPatientId(patientId) {
        patients[patientId].records[recordId] = false;
        patients[patientId].recordsCount--;
    }

    function giveResearcherAccess(uint256 patientId) public {
        patients[patientId].approvedResearcher = true;
    }

    function practitionerGetRecordsCount(uint256 patientId) public view validPatientId(patientId) isApprovedDoctorOrNurse(patientId, tx.origin) returns(uint256) {
        return patients[patientId].recordsCount;
    }



    /********* GETTERS & SETTERS *********/

    function getFirstName(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(string memory) {
        return patients[patientId].firstName;
    }

    function setFirstName(uint256 patientId, string memory _firstName) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].firstName = _firstName;
    }

    function getLastName(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(string memory) {
        return patients[patientId].lastName;
    }

    function setLastName(uint256 patientId, string memory _lastName) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].lastName = _lastName;
    }

    function getEmailAddress(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(string memory) {
        return patients[patientId].emailAddress;
    }

    function setEmailAddress(uint256 patientId, string memory _emailAddress) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].emailAddress = _emailAddress;
    }

    function getDob(uint256 patientId) public view  validPatientId(patientId) ownerOnly(patientId) returns(string memory) {
        return patients[patientId].dob;
    }

    function setDob(uint256 patientId, string memory _dob) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].dob = _dob;
    }

    function isDoctorApproved(uint256 patientId, address doctorAddress) public view returns(bool) {
        return patients[patientId].approvedDoctors[doctorAddress];
    }

    function isNurseApproved(uint256 patientId, address nurseAddress) public view returns(bool) {
        return patients[patientId].approvedNurses[nurseAddress];
    }

    function getApprovedReseacher(uint256 patientId) public view  validPatientId(patientId) returns(bool) {
        return patients[patientId].approvedResearcher;
    }

    function setApprovedResearcher(uint256 patientId, bool _approvedResearcher) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].approvedResearcher = _approvedResearcher;
    }

    function getRecordsCount(uint256 patientId) public view validPatientId(patientId) returns(uint256) {
        return patients[patientId].recordsCount;
    }
    
    function setRecordsCount(uint256 patientId, uint256 _recordsCount) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].recordsCount = _recordsCount;
    }

    function getAcknowledgedRecordsCount(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(uint256) {
        return patients[patientId].acknowledgedRecordsCount;
    }
    
    function setAcknowledgedRecordsCount(uint256 patientId, uint256 _acknowledgedRecordsCount) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].acknowledgedRecordsCount = _acknowledgedRecordsCount;
    }

    function getSecondaryUser(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(address) {
        return patients[patientId].secondaryUser;
    }

    function setSecondaryUser(uint256 patientId, address _secondaryUser) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].secondaryUser = _secondaryUser;
    }

    function getData(uint256 patientId) public view returns(uint256 id,
        string memory firstName,
        string memory lastName,
        string memory emailAddress,
        string memory dob) {
        return (patients[patientId].patientId, patients[patientId].firstName, patients[patientId].lastName, patients[patientId].emailAddress, patients[patientId].dob);
    }

    function getPatientAddress(uint256 patientId) public view validPatientId(patientId) returns(address) {
        return patients[patientId].owner;
    }
}