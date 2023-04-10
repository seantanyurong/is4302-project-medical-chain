pragma solidity ^0.5.0;

import "./Patient.sol";
import "./Doctor.sol";
import "./Nurse.sol";
import "./EHR.sol";
import "./Researcher.sol";


contract medicalChainPatient {

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
  event testEvent(uint256 test);
  event GivingDoctorAccess();
  event RemovingDoctorAccess();
  event GivingNurseAccess();
  event RemovingNurseAccess();
  event GivingResearcherAccess();
  event AddingEHR();
  event AcknowledgingRecord();
  event GettingApprovedPatients();

  /********* MODIFIERS *********/

  // prevent doctor from self-diagnosing, doctor cannot write on their own record
  modifier doctorIsNotPatient(address patientId, address doctorId) {
    require(patientId != doctorId, "Doctor should not self-diagnose");
    _;
  }

  modifier isPractitioner() {
    string memory role = getSenderRole();
    require(keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("doctor"))) || keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("nurse"))), "User is not a practitioner");
    _;
  }

  modifier isPractitionerApprovedAndPatientRegisteredWithPractitioner(uint256 patientId) {
    string memory role = getSenderRole();
    // check if sender is a doctor
    if (keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("doctor")))) {
      require(patientContract.isApprovedDoctor(patientId, msg.sender) == true, "Doctor is not in patient's list of approved doctors");
      require(doctorContract.isPatientInListOfPatients(patientId, msg.sender) == true, "Patient is not in doctor's list of patients");
    } else if (keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("nurse")))) {
      require(patientContract.isApprovedNurse(patientId, msg.sender) == true, "Nurse is not in patient's list of approved nurses");
      require(nurseContract.isPatientInListOfPatients(patientId, msg.sender) == true, "Patient is not in nurse's list of patients");
    }
    _;
  }

  modifier isDoctorApprovedAndPatientRegisteredWithDoctor(uint256 patientId) {
    string memory role = getSenderRole();
    require(keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("doctor"))), "User is not a doctor!");
    require(patientContract.isApprovedDoctor(patientId, msg.sender) == true, "Doctor is not in patient's list of approved doctors");
    require(doctorContract.isPatientInListOfPatients(patientId, msg.sender) == true, "Patient is not in doctor's list of patients");
    _;
  }

modifier isDoctorApprovedAndPatientRegisteredWithDoctorAndIssuer(uint256 patientId, uint256 recordId, address doctorAddress) {
    string memory role = getSenderRole();
    require(keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("doctor"))), "User is not a doctor!");
    require(ehrContract.doesRecordMatchDoctorAddress(recordId, doctorAddress) == true, "Doctor is not issuer!");
    require(patientContract.isApprovedDoctor(patientId, msg.sender) == true, "Doctor is not in patient's list of approved doctors");
    require(doctorContract.isPatientInListOfPatients(patientId, msg.sender) == true, "Patient is not in doctor's list of patients");
    _;
  }

  modifier isPatientAndAuthorised(uint256 patientId) {
    require(keccak256(abi.encodePacked(getSenderRole())) == keccak256(abi.encodePacked(("patient"))), "This person is not a patient!");
    require(patientContract.isValidPatientId(patientId) == true, "Patient ID given is not valid");
    require(patientContract.getPatientIdFromPatientAddress(msg.sender) == patientId, "Patient is not allowed to view other patient's records");
    _;
  }

  modifier isValidDoctorId(uint256 doctorId) {
    require(doctorContract.isValidDoctorId(doctorId) == true, "Doctor ID given is not valid");
    _;
  }

  modifier isValidNurseId(uint256 nurseId) {
    require(nurseContract.isValidNurseId(nurseId) == true, "Nurse ID given is not valid");
    _;
  }

  modifier isValidRecordId(uint256 recordId) {
    require(ehrContract.isValidRecordId(recordId) == true, "Record ID given is not valid");
    _;
  }

  modifier isRecordBelongToPatient(uint256 recordId) {
    require(ehrContract.isRecordBelongToPatient(recordId, msg.sender) == true, "Record does not belong to this patient");
    _;
  }

  modifier isResearcherAbleToViewPatientData(uint256 patientId) {
    require(patientContract.getApprovedReseacher(patientId), "Patient has not approved data for research purposes");
    _;
  }

  modifier isResearcher() {
    require(keccak256(abi.encodePacked(getSenderRole())) == keccak256(abi.encodePacked(("researcher"))), "This person is not a researcher!");
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

  function giveResearcherAccess(uint256 patientId) public {
    emit GivingResearcherAccess();
    patientContract.giveResearcherAccess(patientId);
  }

  function testingTest(uint256 test) public {
    emit testEvent(test);
  }

  // Patient: View all records (acknowledged and not acknowledged)
  function patientViewAllAcknowledgedRecords(uint256 patientId) public view isPatientAndAuthorised(patientId) returns (uint256[] memory) {
    return patientContract.viewAllAcknowledgedRecords(patientId);
  }

  // Patient: View all records (acknowledged and not acknowledged)
  function patientViewAllRecords(uint256 patientId) public view isPatientAndAuthorised(patientId) returns (uint256[] memory) {
    return patientContract.viewAllRecords(patientId);
  }

  // Patient: View all records issued by certain doctor
  function patientViewRecordsByDoctor(uint256 patientId, uint256 doctorId) public view isPatientAndAuthorised(patientId) isValidDoctorId(doctorId) returns (uint256[] memory) {
    // address doctorAddress = doctorContract.getDoctorAddressFromDoctorId(doctorId);
    return patientContract.viewRecordsByDoctor(patientId, doctorContract.getDoctorAddressFromDoctorId(doctorId));
  }

  // Patient: View all records issued by certain nurse
  function patientViewRecordsByNurse(uint256 patientId, uint256 nurseId) public view isValidNurseId(nurseId) returns (uint256[] memory) {
    // address nurseAddress = nurseContract.getNurseAddressFromNurseId(nurseId);
    return patientContract.viewRecordsByDoctor(patientId, nurseContract.getNurseAddressFromNurseId(nurseId));
  }

  // Patient: Filter records by record type
  function patientViewRecordsByRecordType(uint256 patientId, EHR.RecordType recordType) public view isPatientAndAuthorised(patientId) returns (uint256[] memory) {
    return patientContract.viewRecordsByRecordType(patientId, recordType);
  }

// Patient: Acknowledge a record that is added to his medical records
function patientAcknowledgeRecord(uint256 recordId) public isValidRecordId(recordId) isRecordBelongToPatient(recordId) {
  emit AcknowledgingRecord();
  // uint256 patientId = patientContract.getPatientIdFromPatientAddress(msg.sender);
  patientContract.signOffRecord(patientContract.getPatientIdFromPatientAddress(msg.sender), recordId);
}


}