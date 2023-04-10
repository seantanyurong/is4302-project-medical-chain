pragma solidity ^0.5.0;

import "./Patient.sol";
import "./Doctor.sol";
import "./Nurse.sol";
import "./EHR.sol";
import "./Researcher.sol";


contract medicalChainStaff {

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
  event RemovingEHR();
  event AcknowledgingRecord();
  event GettingApprovedPatients();

  /********* MODIFIERS *********/

  // prevent doctor from self-diagnosing, doctor cannot write on their own record
  modifier doctorIsNotPatient(address patientId, address doctorId) {
    require(patientId != doctorId, "Doctor should not self-diagnose");
    _;
  }

  modifier isPractitionerApprovedAndPatientRegisteredWithPractitioner(uint256 patientId) {
    string memory role = getSenderRole();
    require(keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("doctor"))) || keccak256(abi.encodePacked((role))) == keccak256(abi.encodePacked(("nurse"))), "User is not a practitioner");
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

  modifier isDoctorAndAuthorised(uint256 doctorId) {
    require(keccak256(abi.encodePacked(getSenderRole())) == keccak256(abi.encodePacked(("doctor"))), "This person is not a doctor!");
    require(doctorContract.isValidDoctorId(doctorId) == true, "Doctor Id given is not valid");
    require(doctorContract.getDoctorIdFromDoctorAddress(msg.sender) == doctorId, "Doctor is not allowed to act on behalf of other doctor");
    _;
  }

  modifier isNurseAndAuthorised(uint256 nurseId) {
    require(keccak256(abi.encodePacked(getSenderRole())) == keccak256(abi.encodePacked(("nurse"))), "This person is not a nurse!");
    require(nurseContract.isValidNurseId(nurseId) == true, "Nurse Id given is not valid");
    require(nurseContract.getNurseIdFromNurseAddress(msg.sender) == nurseId, "Nurse is not allowed to act on behalf of other doctor");
    _;
  }

  modifier PatientIsRegisteredWithDoctor(uint256 doctorId, uint256 patientId) {
    require(doctorContract.getIsPatientRegistered(doctorId, patientId) == true, "Patient is not registered with doctor");
    _;
  }

  modifier PatientIsNotRegisteredWithDoctor(uint256 doctorId, uint256 patientId) {
    require(doctorContract.getIsPatientRegistered(doctorId, patientId) == false, "Patient is already registered with doctor");
    _;
  }

  modifier PatientIsRegisteredWithNurse(uint256 nurseId, uint256 patientId) {
    require(nurseContract.getIsPatientRegistered(nurseId, patientId) == true, "Patient is not registered with nurse");
    _;
  }

  modifier PatientIsNotRegisteredWithNurse(uint256 nurseId, uint256 patientId) {
    require(nurseContract.getIsPatientRegistered(nurseId, patientId) == false, "Patient is already registered with nurse");
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

  modifier isResearcherAbleToViewPatientData(uint256 patientId) {
    require(keccak256(abi.encodePacked(getSenderRole())) == keccak256(abi.encodePacked(("researcher"))), "This person is not a researcher!");
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

  function registerPatientWithDoctor(uint256 doctorId, uint256 patientId) public isDoctorAndAuthorised(doctorId) PatientIsNotRegisteredWithDoctor(doctorId, patientId) {
    doctorContract.registerPatient(doctorId, patientId);
  }

  function unregisterPatientWithDoctor(uint256 doctorId, uint256 patientId) public isDoctorAndAuthorised(doctorId) PatientIsRegisteredWithDoctor(doctorId, patientId)  {
    doctorContract.unregisterPatient(doctorId, patientId);
  }

  function registerPatientWithNurse(uint256 nurseId, uint256 patientId) public isNurseAndAuthorised(nurseId) PatientIsNotRegisteredWithNurse(nurseId, patientId) {
    nurseContract.registerPatient(nurseId, patientId);
  }

  function unregisterPatientWithNurse(uint256 nurseId, uint256 patientId) public isNurseAndAuthorised(nurseId) PatientIsRegisteredWithNurse(nurseId, patientId) {
    nurseContract.registerPatient(nurseId, patientId);
  }

  function testingTest(uint256 test) public {
    emit testEvent(test);
  }

  // Add new EHR
  function addNewEHR(EHR.RecordType recordType, uint256 patientId, string memory filename) public isDoctorApprovedAndPatientRegisteredWithDoctor(patientId) returns (uint256 recordId) {
    
      recordId = ehrContract.add(recordType, filename, patientContract.getPatientAddress(patientId), msg.sender);

      patientContract.addEHR(patientId, recordId);

      emit AddingEHR();
      return recordId;
  }

  // Remove EHR
  function removeEHR(uint256 recordId, uint256 patientId) public isDoctorApprovedAndPatientRegisteredWithDoctor(patientId) {
    
      patientContract.removeEHR(patientId, recordId);

      emit RemovingEHR();
  }

  // Request to view specific record
  function practitionerViewRecordByRecordID(uint256 patientId, uint256 recordId) public view isPractitionerApprovedAndPatientRegisteredWithPractitioner(patientId) isValidRecordId(recordId) returns (uint256 id,
        EHR.RecordType recordType,
        string memory fileName,
        address patientAddress,
        address doctorAddress,
        uint256 timeAdded,
        bool patientSignedOff) {
      return ehrContract.getRecord(recordId);
  }

  // Request to update specific record - update RecordType and fileName
  function updateRecordByRecordId(uint256 patientId, uint256 recordId, EHR.RecordType recordType, string memory fileName) public isDoctorApprovedAndPatientRegisteredWithDoctorAndIssuer(patientId, recordId, msg.sender) isValidRecordId(recordId) {
    ehrContract.updateRecord(recordId, recordType, fileName);
  }

  // Researcher: View all patients who have approved research access
  function viewApprovedPatients() public view isResearcher() returns (uint256[] memory) {
      // emit GettingApprovedPatients();
      return patientContract.getResearchPatients();
  }

  // Researcher: Request to view specific patient data
  function viewPatientByPatientID(uint256 patientID) public view isResearcherAbleToViewPatientData(patientID) returns (uint256 id,
        string memory firstName,
        string memory lastName,
        string memory emailAddress,
        string memory dob) {
      return patientContract.getData(patientID);
  }

  // Practitioner: View all records belonging to this patient
  // Returns all the recordIds
  function practitionerViewAllRecords(uint256 patientId) public view isPractitionerApprovedAndPatientRegisteredWithPractitioner(patientId) returns (uint256[] memory) {
    // address patientAddress = patientContract.getPatientAddress(patientId);
    return patientContract.viewAllRecords(patientId);
  }

    // Patient: Filter records by record type
  function practitionerViewRecordsByRecordType(uint256 patientId, EHR.RecordType recordType) public view isPractitionerApprovedAndPatientRegisteredWithPractitioner(patientId) returns (uint256[] memory) {
    return patientContract.viewRecordsByRecordType(patientId, recordType);
  }


}