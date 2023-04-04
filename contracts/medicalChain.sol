pragma solidity ^0.5.0;

import "./Patient.sol";
import "./Doctor.sol";
import "./Nurse.sol";
import "./EHR.sol";
import "./Researcher.sol";


contract medicalChain {

  Patient patientContract;
  Doctor doctorContract;
  Nurse nurseContract;
  EHR ehrContract;
  Researcher researcherContract;


  constructor(Patient patientAddress, Doctor doctorAddress, Nurse nurseAddress, EHR ehrAddress, Researcher researcherAddress) public {
    patientContract = patientAddress;
    doctorContract = doctorAddress;
    nurseContract = nurseAddress;
    ehrContract = ehrAddress;
    researcherContract = researcherAddress;
  }

  uint256[] recordIds;
  uint256[] patientRecordId;
  /********* EVENTS *********/  

  event PatientAdded(address patientId);
  event DoctorAdded(address doctorId);
  event NurseAdded(address nurseId);
  event testEvent(uint256 test);
  event GivingDoctorAccess();
  event RemovingDoctorAccess();
  event GivingNurseAccess();
  event RemovingNurseAccess();
  event AddingEHR();

  /********* MODIFIERS *********/

  // prevent doctor from self-diagnosing, doctor cannot write on their own record
  modifier doctorIsNotPatient(address patientId, address doctorId) {
    require(patientId != doctorId, "Doctor should not self-diagnose");
    _;
  }

  modifier isValidPractioner(uint256 patientId) {
    string memory role = getSenderRole();
    if (keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("doctor")))) {
      require(patientContract.isApprovedDoctor(patientId, msg.sender) == true, "Doctor is not in patient's list of approved doctors");
    } else if (keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("nurse")))) {
      require(patientContract.isApprovedNurse(patientId, msg.sender) == true, "Nurse is not in patient's list of approved nurses");
    }
    _;
  }

  modifier isValidPatientId(uint256 patientId) {
    require(patientContract.isValidPatientId(patientId) == true, "Patient ID given is not valid");
    _;
  }

  modifier isCorrectPatient() {
    require(patientContract.isSender(msg.sender) == true, "Patient is not allowed to do this action");
    _;
  }

  modifier isRecordBelongToPatient(uint256 recordId) {
    require(ehrContract.isRecordBelongToPatient(recordId, msg.sender) == true, "Record does not belong to this patient");
    _;
  }

  modifier isPatientRegisteredWithPractioner(uint256 patientId) {
    string memory role = getSenderRole();
    if (keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("doctor")))) {
      require(doctorContract.isPatientInListOfPatients(patientId, msg.sender) == true, "Patient is not in doctor's list of patients");
    } else if (keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("nurse")))) {
      require(nurseContract.isPatientInListOfPatients(patientId, msg.sender) == true, "Patient is not in nurse's list of patients");
    }
    _;
  }

  modifier isPractionerAbleToViewRecord(uint256 recordId) {
    require(patientContract.isApprovedDoctor(patientContract.getPatientIdFromPatientAddress(ehrContract.getPatientAddress(recordId)), msg.sender), "Doctor/Nurse is not able to view this record as they are not the issuer");
    _;
  }

  modifier isResearcherAbleToViewRecord(uint256 patientId) {
    require(patientContract.getApprovedReseacher(patientId), "Patient has not approved data for research purposes");
    _;
  }

  modifier isResearcher() {
    require(keccak256(abi.encodePacked(getSenderRole())) == keccak256(abi.encodePacked(("researcher"))));
    _;
  }


  /********* FUNCTIONS *********/

  function getSenderRole() public view returns (string memory) {
    if (doctorContract.isSender(msg.sender)) {
      return "doctor";
    } else if (patientContract.isSender(msg.sender)) {
      return "patient";
    } else if (nurseContract.isSender(msg.sender)) {
      return "nurse";
    } else if (researcherContract.isSender(msg.sender)) {
      return "researcher";
    } else {
      return "unknown";
    }
  }

  function giveDoctorAccess(uint256 patientId, address doctorAddress) public {
    emit GivingDoctorAccess();
    patientContract.giveDoctorAccess(patientId, doctorAddress);
  }

  function removeDoctorAccess(uint256 patientId, address doctorAddress) public {
    emit RemovingDoctorAccess();
    patientContract.removeDoctorAccess(patientId, doctorAddress);
  }

  function giveNurseAccess(uint256 patientId, address nurseAddress) public {
    emit GivingNurseAccess();
    patientContract.giveNurseAccess(patientId, nurseAddress);
  }

  function removeNurseAccess(uint256 patientId, address nurseAddress) public {
    emit RemovingNurseAccess();
    patientContract.removeNurseAccess(patientId, nurseAddress);
  }

  function testingTest(uint256 test) public {
    emit testEvent(test);
  }

  // Add new EHR
  function addNewEHR(EHR.RecordType recordType, uint256 patientId, string memory filename) public payable isValidPractioner(patientId) isPatientRegisteredWithPractioner(patientId) returns (uint256 recordId) {

      // Check if msg.sender is doctor or nurse
      // Check if msg.sender is inside patient's approvedDoctors or approvedNurses
      // Check if patientId inside doctor's patients
      // Add new EHR
      // add recordId into patient and doctors records

      address patientAddress = patientContract.getPatientAddress(patientId);
      recordId = ehrContract.add(recordType, filename, patientAddress, msg.sender);

      recordIds.push(recordId);

      patientContract.addEhr(patientId, recordId);

      emit AddingEHR();
      return recordId;
  }

  // Request to view specific record
  function viewRecordByRecordID(uint256 recordId) public isPractionerAbleToViewRecord(recordId) returns (uint256 id,
        EHR.RecordType recordType,
        string memory fileName,
        address patientAddress,
        address doctorAddress,
        uint256 timeAdded) {
      return ehrContract.getRecord(recordId);
  }

  // Request to update specific record - update RecordType and fileName
  function updateRecordByRecordID(uint256 recordId, EHR.RecordType recordType, string memory fileName) public isPractionerAbleToViewRecord(recordId) {
    ehrContract.updateRecord(recordId, recordType, fileName);
  }

  // Researcher: View all patients who have approved research access
  function viewApprovedPatients() public view isResearcher returns (uint256[] memory) {
      return patientContract.getResearchPatients();
  }

  // Researcher: Request to view specific patient data
  function viewPatientByPatientID(uint256 patientID) public view isResearcher isResearcherAbleToViewRecord(patientID) returns (uint256 id,
        string memory firstName,
        string memory lastName,
        string memory emailAddress,
        string memory dob) {
      return patientContract.getData(patientID);
  }

  // Patient: View all records that are acknowledged by patient
  function viewAllRecords(uint256 patientId) public view isCorrectPatient() isValidPatientId(patientId) returns (uint256[] memory) {
    // only when it is signed off, then it is counted
    // if need to be counted regardless of signed off, increment it in addNewEHR function
    uint256 patientNoOfRecords = patientContract.getRecordsCount(patientId);
    uint256[] memory patientRecordsId = new uint256[](patientNoOfRecords);
    uint256 indexTracker = 0;
    for (uint256 i = 0; i < ehrContract.numEHR(); i++) {
      // record belongs to patient calling it AND whether the record is acknowledged
      if (ehrContract.isRecordBelongToPatient(i, msg.sender) && patientContract.isRecordAcknowledged(patientId, i)) {
        patientRecordsId[indexTracker] = i;
        indexTracker++;
      }
    }

    return patientRecordsId;
  }

  // Patient: Filter records by record type
  function filterRecordsByRecordType(uint256 patientId, EHR.RecordType recordType) public view isCorrectPatient() isValidPatientId(patientId) returns (uint256[] memory) {
    uint256[] memory patientRecordsId = viewAllRecords(patientId);
    uint256 noOfPatientRecords = patientContract.getRecordsCount(patientId);
    uint256 noOfFilteredRecords = numberOfRecordType(patientId, recordType);
    uint256[] memory patientRecordsIdFiltered = new uint256[](noOfFilteredRecords);
    uint256 indexTracker = 0;
    for (uint256 i = 0; i < noOfPatientRecords; i++) {
      uint256 currentRecordId = patientRecordsId[i];
      if (ehrContract.doesRecordMatchRecordType(currentRecordId, recordType)) {
        patientRecordsIdFiltered[indexTracker] = currentRecordId;
        indexTracker++;
      }
    }

    return patientRecordsIdFiltered;
  }

  // Patient: Helper function to check how many records fulfilling the given record type for a patient
  function numberOfRecordType(uint256 patientId, EHR.RecordType recordType) public view isCorrectPatient() isValidPatientId(patientId) returns(uint256){ // change on what you need to return
    uint256[] memory patientRecordsId = viewAllRecords(patientId);
    uint256 noOfPatientRecords = patientContract.getRecordsCount(patientId);
    uint256 noOfRecordsMatchingRecordType = 0;
    for (uint256 i = 0; i < noOfPatientRecords; i++) {
      uint256 currentRecordId = patientRecordsId[i];
      if (ehrContract.doesRecordMatchRecordType(currentRecordId, recordType)) {
        noOfRecordsMatchingRecordType++;
      }
    }

    return noOfRecordsMatchingRecordType;
}


// View all records belonging to this patient
// Returns all the recordIds
function filterRecordsByPatient(uint256 patientId) public isCorrectPatient() returns (uint256[] memory) {
  delete patientRecordId;
  for (uint i = 0; i < recordIds.length; i++) {
    uint256 currRecordId = recordIds[i];
    address patientAddress = ehrContract.getPatientAddress(currRecordId);
    uint256 thisPatientId = patientContract.getPatientIdFromPatientAddress(patientAddress);
    if (thisPatientId == patientId) {
      patientRecordId.push(currRecordId);
    }
  }
  return patientRecordId;
}


// View all records signed off by certain practitioner

function filterRecordsByPractitioner(uint256 practitionerId) public isCorrectPatient() returns (uint256[] memory) {
  delete patientRecordId;
  for (uint i = 0; i < recordIds.length; i++) {
    uint256 currRecordId = recordIds[i];
    address doctorAddress = ehrContract.getDoctorAddress(currRecordId);
    uint256 thisPractitionerId = doctorContract.getDoctorIdFromDoctorAddress(doctorAddress);
    if (thisPractitionerId == practitionerId) {
      patientRecordId.push(currRecordId);
    }
  }
  return patientRecordId;
  }



// Patient: Acknowledge a record that is added to his medical records
function patientAcknowledgeRecord(uint256 recordId) public isCorrectPatient() isRecordBelongToPatient(recordId) {
  uint256 patientId = patientContract.getPatientIdFromPatientAddress(msg.sender);
  patientContract.signOffRecord(patientId, recordId);
}

}