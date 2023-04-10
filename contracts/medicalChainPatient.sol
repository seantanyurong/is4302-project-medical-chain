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

  modifier isPatientAndAuthorised(uint256 patientId) {
    require(keccak256(abi.encodePacked(getSenderRole())) == keccak256(abi.encodePacked(("patient"))), "This person is not a patient!");
    require(patientContract.isValidPatientId(patientId) == true, "Patient ID given is not valid");
    require(patientContract.getPatientIdFromPatientAddress(msg.sender) == patientId, "This patient is not allowed to call on behalf of other patient");
    _;
  }

  modifier isValidDoctorId(uint256 doctorId) {
    require(doctorContract.isValidDoctorId(doctorId) == true, "Doctor ID given is not valid");
    _;
  }

  modifier isValidDoctorAddress(address doctorAddress) {
    require(doctorContract.getDoctorIdFromDoctorAddress(doctorAddress) != uint256(-1), "Doctor address given is not valid");
    _;
  }


  modifier isValidNurseId(uint256 nurseId) {
    require(nurseContract.isValidNurseId(nurseId) == true, "Nurse ID given is not valid");
    _;
  }

  modifier isValidNurseAddress(address nurseAddress) {
    require(nurseContract.getNurseIdFromNurseAddress(nurseAddress) != uint256(-1), "Nurse ID given is not valid");
    _;
  }

  modifier isValidRecordId(uint256 recordId) {
    require(ehrContract.isValidRecordId(recordId) == true, "Record ID given is not valid");
    _;
  }

  modifier isRecordBelongToPatient(uint256 recordId) {
    require(keccak256(abi.encodePacked(getSenderRole())) == keccak256(abi.encodePacked(("patient"))), "This person is not a patient!");
    require(ehrContract.isRecordBelongToPatient(recordId, msg.sender) == true, "Record does not belong to this patient");
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

  function giveDoctorAccess(uint256 patientId, address doctorAddress) public isPatientAndAuthorised(patientId) isValidDoctorAddress(doctorAddress)  {
    emit GivingDoctorAccess();
    patientContract.giveDoctorAccess(patientId, doctorAddress);
  }

  function removeDoctorAccess(uint256 patientId, address doctorAddress) public isPatientAndAuthorised(patientId) isValidDoctorAddress(doctorAddress) {
    emit RemovingDoctorAccess();
    patientContract.removeDoctorAccess(patientId, doctorAddress);
  }

  function giveNurseAccess(uint256 patientId, address nurseAddress) public isPatientAndAuthorised(patientId) isValidNurseAddress(nurseAddress)  {
    emit GivingNurseAccess();
    patientContract.giveNurseAccess(patientId, nurseAddress);
  }

  function removeNurseAccess(uint256 patientId, address nurseAddress) public isPatientAndAuthorised(patientId) isValidNurseAddress(nurseAddress) {
    emit RemovingNurseAccess();
    patientContract.removeNurseAccess(patientId, nurseAddress);
  }

  function giveResearcherAccess(uint256 patientId) public isPatientAndAuthorised(patientId) {
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
    return patientContract.viewRecordsByDoctor(patientId, doctorContract.getDoctorAddressFromDoctorId(doctorId));
  }

  // Patient: Filter records by record type
  function patientViewRecordsByRecordType(uint256 patientId, EHR.RecordType recordType) public view isPatientAndAuthorised(patientId) returns (uint256[] memory) {
    return patientContract.viewRecordsByRecordType(patientId, recordType);
  }

// Patient: Acknowledge a record that is added to his medical records
function patientAcknowledgeRecord(uint256 recordId) public isValidRecordId(recordId) isRecordBelongToPatient(recordId) {
  emit AcknowledgingRecord();
  patientContract.signOffRecord(patientContract.getPatientIdFromPatientAddress(msg.sender), recordId);
}


}