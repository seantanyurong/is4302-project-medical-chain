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

  event PatientAdded(address patientId);
  event DoctorAdded(address doctorId);
  event NurseAdded(address nurseId);

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

  // Edit patient profile 

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
        string memory fileName,
        address patientAddress,
        address doctorAddress,
        uint256 timeAdded) {
      return ehrContract.getRecord(recordId);
  }

  // View all patients who have approved research access
  function viewApprovedPatients() public view isResearcher returns (uint256[] memory) {
      return patientContract.getResearchPatients();
  }

  // Request to view specific patient data
  function viewPatientByPatientID(uint256 patientID) public view isResearcher isResearcherAbleToViewRecord(patientID) returns (uint256 id,
        string memory firstName,
        string memory lastName,
        string memory emailAddress,
        string memory dob) {
      return patientContract.getData(patientID);
  }


}


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