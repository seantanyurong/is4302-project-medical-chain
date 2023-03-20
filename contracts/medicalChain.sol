pragma solidity ^0.5.0;
import "./Patient.sol";
import "./Doctor.sol";
import "./Nurse.sol";
import "./EHR.sol";

contract medicalChain {

  Patient patient;
  Doctor doctor;
  Nurse nurse;
    
  // struct Record { 
  //   string cid;
  //   string fileName; 
  //   address patientId;
  //   address doctorId;
  //   uint256 timeAdded;
  // }

  // struct Patient {
  //   address id;
  //   mapping(uint256 => Record) records;
  //   mapping(address => Doctor) doctorsWithAccess;
  //   mapping(address => Nurse) nursesWithAccess;
  // }

  // struct Doctor {
  //   address id;
  // }

  // struct Nurse {
  //   address id;
  // }

  // mapping (address => Patient) public patients;
  // mapping (address => Doctor) public doctors;
  // mapping (address => Nurse) public nurses;

  event PatientAdded(address patientId);
  event DoctorAdded(address doctorId);
  event NurseAdded(address nurseId);

  // modifier senderExists {
  //   require(doctors[msg.sender].id == msg.sender|| nurses[msg.sender].id == msg.sender || patients[msg.sender].id == msg.sender, "Sender does not exist");
  //   _;
  // }

  // modifier patientExists(uint256 patientId) {
  //   require(Patient.patientExists(patientId), "Patient does not exist");
  //   _;
  // }

  // modifier doctorExists(address doctorId) {
  //   require(doctors[doctorId].id == doctorId, "Doctor does not exist");
  //   _;
  // }

  // modifier nurseExists(address nurseId) {
  //   require(nurses[nurseId].id == nurseId, "Nurse does not exist");
  //   _;
  // }

  // modifier senderIsDoctor {
  //   require(doctors[msg.sender].id == msg.sender, "Sender is not a doctor");
  //   _;
  // }

  // to ensure sender is the one who wrote on the chain (for secondary access)
  // modifier senderIsWriter(Record memory record) {
  //   require(record.doctorId == msg.sender, "Sender is not the writer(doctor) of the Record");
  //   _;
  // }

  // modifier senderIsPatient(uint256 patientId) {
  //   require(Patient.senderIsPatient(patientId), "Sender is not the patient");
  //   _;
  // }

  // prevent doctor from self-diagnosing, doctor cannot write on their own record
  modifier doctorIsNotPatient(address patientId, address doctorId) {
    require(patientId != doctorId, "Doctor should not self-diagnose");
    _;
  }

  // msg.sender will be the patient
  // function addPatient() public {
    // require(patients[msg.sender].id != msg.sender, "This patient already exists.");

    // Patient memory newPatient = Patient({
    //   id: msg.sender
    // });
    // patients[msg.sender] = newPatient;

    // emit PatientAdded(msg.sender);
  // }

  // msg.sender will be the doctor
  // function addDoctor() public {
  //   require(doctors[msg.sender].id != msg.sender, "This doctor already exists.");

  //   Doctor memory newDoctor = Doctor({
  //     id: msg.sender
  //   });
  //   doctors[msg.sender] = newDoctor;

  //   emit DoctorAdded(msg.sender);
  // }

  // msg.sender will be the nurse
  // function addNurse() public {
  //   require(nurses[msg.sender].id != msg.sender, "This nurse already exists.");

  //   Nurse memory newNurse = Nurse({
  //     id: msg.sender
  //   });
  //   nurses[msg.sender] = newNurse;

  //   emit NurseAdded(msg.sender);
  // }



  // patient calls the function
  // function giveDoctorAccess(address doctorId) public 
  //   senderIsPatient(msg.sender) doctorIsNotPatient(msg.sender, doctorId) patientExists(msg.sender) doctorExists(doctorId) {
  //   Patient storage p = patients[msg.sender];
  //   Doctor memory d = doctors[doctorId];

  //   p.doctorsWithAccess[doctorId] = d;
  // }

  function giveDoctorAccess(uint256 patientId, uint256 doctorId) public {
    patient.giveDoctorAccess(patientId, doctorId);
  }

  function removeDoctorAccess(uint256 patientId, uint256 doctorId) public {
    patient.removeDoctorAccess(patientId, doctorId);
  }

  function giveNurseAccess(uint256 patientId, uint256 nurseId) public {
    patient.giveNurseAccess(patientId, nurseId);
  }

  function removeNurseAccess(uint256 patientId, uint256 nurseId) public {
    patient.removeNurseAccess(patientId, nurseId);
  }



  // patient calls the function
  // function giveNurseAccess(address nurseId) public 
  //   senderIsPatient(msg.sender) patientExists(msg.sender) nurseExists(nurseId) {
  //   Patient storage p = patients[msg.sender];
  //   Nurse memory n = nurses[nurseId];

  //   p.nursesWithAccess[nurseId] = n;
  // }

  // patient calls the function
  // function removeDoctorAccess(address doctorId) public 
  //   senderIsPatient(msg.sender) doctorIsNotPatient(msg.sender, doctorId) patientExists(msg.sender) doctorExists(doctorId) {
  //   Patient storage p = patients[msg.sender];
  //   delete p.doctorsWithAccess[doctorId];
  // }

  // patient calls the function
  // function removeNurseAccess(address nurseId) public 
  //   senderIsPatient(msg.sender) patientExists(msg.sender) nurseExists(nurseId) {
  //   Patient storage p = patients[msg.sender];
  //   delete p.nursesWithAccess[nurseId];
  // }

  function getSenderRole() public view returns (string memory) {
    if (doctor.isSender(msg.sender)) {
      return "doctor";
    } else if (patient.isSender(msg.sender)) {
      return "patient";
    } else if (nurse.isSender(msg.sender)) {
      return "nurse";
    } else {
      return "unknown";
    }
  }

  // Edit patient profile 

  // Add new EHR
  function addNewEHR(uint256 patientId, string memory filename) public view returns (uint256 recordId) {
      // Check if msg.sender is doctor or nurse
      // Check if msg.sender is inside patient's approvedDoctors or approvedNurses
      // Check if patientId inside doctor's patients
      // Add new EHR
      // add recordId into patient and doctors records
  }

  // Request to view specific record
  function viewRecordByRecordID(uint256 recordId) public view returns (EHR record) {
      // Check if msg.sender is doctor or nurse
      // Check if msg.sender inside record's doctors or nurses
      // return record
  }

}

