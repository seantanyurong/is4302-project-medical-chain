pragma solidity ^0.5.0;

contract medicalChain {
    
  struct Record { 
    string cid;
    string fileName; 
    address patientId;
    address doctorId;
    uint256 timeAdded;
  }

  struct Patient {
    address id;
    uint256 noOfRecords;
    mapping(uint256 => Record) records;
    mapping(address => Doctor) doctorsWithAccess;
    mapping(address => Nurse) nursesWithAccess;
  }

  struct Doctor {
    address id;
  }

  struct Nurse {
    address id;
  }

  mapping (address => Patient) public patients;
  mapping (address => Doctor) public doctors;
  mapping (address => Nurse) public nurses;

  event PatientAdded(address patientId);
  event DoctorAdded(address doctorId);
  event NurseAdded(address nurseId);

  modifier senderExists {
    require(doctors[msg.sender].id == msg.sender|| nurses[msg.sender].id == msg.sender || patients[msg.sender].id == msg.sender, "Sender does not exist");
    _;
  }

  modifier patientExists(address patientId) {
    require(patients[patientId].id == patientId, "Patient does not exist");
    _;
  }

  modifier doctorExists(address doctorId) {
    require(doctors[doctorId].id == doctorId, "Doctor does not exist");
    _;
  }

  modifier nurseExists(address nurseId) {
    require(nurses[nurseId].id == nurseId, "Nurse does not exist");
    _;
  }

  modifier senderIsDoctor {
    require(doctors[msg.sender].id == msg.sender, "Sender is not a doctor");
    _;
  }

  // to ensure sender is the one who wrote on the chain (for secondary access)
  modifier senderIsWriter(Record memory record) {
    require(record.doctorId == msg.sender, "Sender is not the writer(doctor) of the Record");
    _;
  }

  modifier senderIsPatient(address patientId) {
    require(patientId == msg.sender, "Sender is not the patient");
    _;
  }

  // prevent doctor from self-diagnosing, doctor cannot write on their own record
  modifier doctorIsNotPatient(address patientId, address doctorId) {
    require(patientId != doctorId, "Doctor should not self-diagnose");
    _;
  }

  // to ensure record exists (to clarify what is cid)
  /*
  modifier recordExists(address patientId, uint256 recordId) {
    
  }
  */

  modifier senderIsAuthorised(address patientId) {
    string memory role = getSenderRole();
    if (keccak256(bytes(role)) == keccak256(bytes("doctor"))) {
        require(patients[patientId].doctorsWithAccess[msg.sender].id == msg.sender);
    } else if (keccak256(bytes(role)) == keccak256(bytes("nurse"))) {
        require(patients[patientId].nursesWithAccess[msg.sender].id == msg.sender);
    } else if (keccak256(bytes(role)) == keccak256(bytes("patient"))) {
      
    }
    _;
  }

  // msg.sender will be the patient
  function addPatient() public {
    require(patients[msg.sender].id != msg.sender, "This patient already exists.");

    Patient memory newPatient = Patient({
      id: msg.sender,
      noOfRecords: 0
    });
    patients[msg.sender] = newPatient;

    emit PatientAdded(msg.sender);
  }

  // msg.sender will be the doctor
  function addDoctor() public {
    require(doctors[msg.sender].id != msg.sender, "This doctor already exists.");

    Doctor memory newDoctor = Doctor({
      id: msg.sender
    });
    doctors[msg.sender] = newDoctor;

    emit DoctorAdded(msg.sender);
  }

  // msg.sender will be the nurse
  function addNurse() public {
    require(nurses[msg.sender].id != msg.sender, "This nurse already exists.");

    Nurse memory newNurse = Nurse({
      id: msg.sender
    });
    nurses[msg.sender] = newNurse;

    emit NurseAdded(msg.sender);
  }

  // patient calls the function
  function giveDoctorAccess(address doctorId) public 
    senderIsPatient(msg.sender) doctorIsNotPatient(msg.sender, doctorId) patientExists(msg.sender) doctorExists(doctorId) {
    Patient storage p = patients[msg.sender];
    Doctor memory d = doctors[doctorId];

    p.doctorsWithAccess[doctorId] = d;
  }

  // patient calls the function
  function giveNurseAccess(address nurseId) public 
    senderIsPatient(msg.sender) patientExists(msg.sender) nurseExists(nurseId) {
    Patient storage p = patients[msg.sender];
    Nurse memory n = nurses[nurseId];

    p.nursesWithAccess[nurseId] = n;
  }

  // patient calls the function
  function removeDoctorAccess(address doctorId) public 
    senderIsPatient(msg.sender) doctorIsNotPatient(msg.sender, doctorId) patientExists(msg.sender) doctorExists(doctorId) {
    Patient storage p = patients[msg.sender];
    delete p.doctorsWithAccess[doctorId];
  }

  // patient calls the function
  function removeNurseAccess(address nurseId) public 
    senderIsPatient(msg.sender) patientExists(msg.sender) nurseExists(nurseId) {
    Patient storage p = patients[msg.sender];
    delete p.nursesWithAccess[nurseId];
  }

  // patient calls to view all his/her record
  function viewAllRecords() public view senderIsPatient(msg.sender) patientExists(msg.sender) {
    Patient storage p = patients[msg.sender];
    for (uint i = 0; i < p.noOfRecords; i++) {
      // do something with below code (to confirm again)
      // p.records[i]
    }
  }

  // nurses or doctors call to get a patient's record
  function getRecord(uint256 recordId, address patientAddress) public patientExists(patientAddress) senderIsAuthorised(patientAddress) view
  returns (
    string memory _cid,
    string memory _fileName,
    address _patientId,
    address _doctorId,
    uint256 _timeAdded
  )
    {
    Patient storage p = patients[msg.sender];
    _cid = p.records[recordId].cid;
    _fileName = p.records[recordId].fileName;
    _patientId = p.records[recordId].patientId;
    _doctorId = p.records[recordId].doctorId;
    _timeAdded = p.records[recordId].timeAdded;
  }

  function getSenderRole() public view returns (string memory) {
    if (doctors[msg.sender].id == msg.sender) {
      return "doctor";
    } else if (patients[msg.sender].id == msg.sender) {
      return "patient";
    } else if (nurses[msg.sender].id == msg.sender) {
      return "nurse";
    } else {
      return "unknown";
    }
  }
}

