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

  /********* EVENTS *********/  

  event PatientAdded(address patientId);
  event DoctorAdded(address doctorId);
  event NurseAdded(address nurseId);



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

  modifier isCorrectPatient() {
    require(patientContract.isSender(msg.sender) == true, "Patient is not allowed to view this patient record");
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
    require(ehrContract.getDoctorAddress(recordId) == msg.sender, "Doctor/Nurse is not able to view this record as they are not the issuer");
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
    patientContract.giveDoctorAccess(patientId, doctorAddress);
  }

  function removeDoctorAccess(uint256 patientId, address doctorAddress) public {
    patientContract.removeDoctorAccess(patientId, doctorAddress);
  }

  function giveNurseAccess(uint256 patientId, address nurseAddress) public {
    patientContract.giveNurseAccess(patientId, nurseAddress);
  }

  function removeNurseAccess(uint256 patientId, address nurseAddress) public {
    patientContract.removeNurseAccess(patientId, nurseAddress);
  }

  // Add new EHR
  function addNewEHR(uint256 patientId, string memory filename) public view isValidPractioner(patientId) isPatientRegisteredWithPractioner(patientId) returns (uint256 recordId) {

      // Check if msg.sender is doctor or nurse
      // Check if msg.sender is inside patient's approvedDoctors or approvedNurses
      // Check if patientId inside doctor's patients
      // Add new EHR
      // add recordId into patient and doctors records
  }

  // Request to view specific record
  function viewRecordByRecordID(uint256 recordId) public view isPractionerAbleToViewRecord(recordId) returns (uint256 id,
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

  /* 
To do: Aaron

  function filterRecordsByRecordType(EHR.RecordType recordType) public view isCorrectPatient() returns (records) {
    // with bool[] of i -> bool, those with true are records with that record type
    // qns: how to output the records? (concern: multiple)
  }

  function checkRecordType(EHR.RecordType recordType) public pure returns(bool[] memory){ // change on what you need to return

    bool[] memory checker; // change on what you need to return

    // for loop through length of all records
    // check for each record that record type = stated record type
    // mark that id as true
    // return the bool[]
    return checker;
}

*/

// View all records belonging to this patient
/*
function filterRecordsByPatient(uint256 patientId) public view isCorrectPatient() returns (records) {

}
*/

// View all records signed off by certain practitioner
/*
function filterRecordsByPractitioner(uint256 practitionerId) public view isCorrectPatient() returns (records) {

}
*/

// Patient: Acknowledge a record that is added to his medical records
function patientAcknowledgeRecord(uint256 recordId) public isCorrectPatient() isRecordBelongToPatient(recordId) {
  uint256 patientId = patientContract.getPatientIdFromPatientAddress(msg.sender);
  patientContract.signOffRecord(patientId, recordId);
}

}