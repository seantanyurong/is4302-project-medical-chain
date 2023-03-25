pragma solidity ^0.5.0;
import "./Patient.sol";
import "./Doctor.sol";
import "./Nurse.sol";

contract medicalChain {

  Patient patientContract;
  Doctor doctorContract;
  Nurse nurseContract;
  EHR ehrContract;

  constructor(Patient patientAddress, Doctor doctorAddress, Nurse nurseAddress, EHR ehrAddress) public {
        patientContract = patientAddress;
        doctorContract = doctorAddress;
        nurseContract = nurseAddress;
        ehrContract = ehrAddress;
    }
    
  // struct Record { 
  //   string cid;
  //   string fileName; 
  //   address patientId;
  //   address doctorId;
  //   uint256 timeAdded;
  // }

  // struct patientContract {
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

  // mapping (address => patientContract) public patients;
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
  //   require(patientContract.patientExists(patientId), "patientContract does not exist");
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
  //   require(patientContract.senderIsPatient(patientId), "Sender is not the patientContract");
  //   _;
  // }

  // prevent doctor from self-diagnosing, doctor cannot write on their own record
  modifier doctorIsNotPatient(address patientId, address doctorId) {
    require(patientId != doctorId, "Doctor should not self-diagnose");
    _;
  }

  // msg.sender will be the patientContract
  // function addPatient() public {
    // require(patients[msg.sender].id != msg.sender, "This patientContract already exists.");

    // patientContract memory newPatient = patientContract({
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



  // patientContract calls the function
  // function giveDoctorAccess(address doctorId) public 
  //   senderIsPatient(msg.sender) doctorIsNotPatient(msg.sender, doctorId) patientExists(msg.sender) doctorExists(doctorId) {
  //   patientContract storage p = patients[msg.sender];
  //   Doctor memory d = doctors[doctorId];

  //   p.doctorsWithAccess[doctorId] = d;
  // }

  function giveDoctorAccess(uint256 patientId, uint256 doctorId) public {
    patientContract.giveDoctorAccess(patientId, doctorId);
  }

  function removeDoctorAccess(uint256 patientId, uint256 doctorId) public {
    patientContract.removeDoctorAccess(patientId, doctorId);
  }

  function giveNurseAccess(uint256 patientId, uint256 nurseId) public {
    patientContract.giveNurseAccess(patientId, nurseId);
  }

  function removeNurseAccess(uint256 patientId, uint256 nurseId) public {
    patientContract.removeNurseAccess(patientId, nurseId);
  }


  // patientContract calls the function
  // function giveNurseAccess(address nurseId) public 
  //   senderIsPatient(msg.sender) patientExists(msg.sender) nurseExists(nurseId) {
  //   patientContract storage p = patients[msg.sender];
  //   Nurse memory n = nurses[nurseId];

  //   p.nursesWithAccess[nurseId] = n;
  // }

  // patientContract calls the function
  // function removeDoctorAccess(address doctorId) public 
  //   senderIsPatient(msg.sender) doctorIsNotPatient(msg.sender, doctorId) patientExists(msg.sender) doctorExists(doctorId) {
  //   patientContract storage p = patients[msg.sender];
  //   delete p.doctorsWithAccess[doctorId];
  // }

  // patientContract calls the function
  // function removeNurseAccess(address nurseId) public 
  //   senderIsPatient(msg.sender) patientExists(msg.sender) nurseExists(nurseId) {
  //   patientContract storage p = patients[msg.sender];
  //   delete p.nursesWithAccess[nurseId];
  // }

  function getSenderRole() public view returns (string memory) {
    if (doctorContract.isSender(msg.sender)) {
      return "doctor";
    } else if (patientContract.isSender(msg.sender)) {
      return "patientContract";
    } else if (nurseContract.isSender(msg.sender)) {
      return "nurse";
    } else {
      return "unknown";
    }
  }


  function viewAllRecordsAsDoctor(uint256 patientId) public view {
    require(patientId < patientContract.numPatients());
    // require that doctor is approved

    for (uint256 i = 0; i < ehrContract.)

      // for recordids that are approved in the patient's record from Patient
  // use that recordid to get the record from EHR

  }

  function

  // Edit patientContract profile 

  
}

