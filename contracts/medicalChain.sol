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
    Record[] records;
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

  modifier senderIsDoctor {
    require(doctors[msg.sender].id == msg.sender, "Sender is not a doctor");
    _;
  }

  function addPatient(address _patientId) public senderIsDoctor {
    require(patients[_patientId].id != _patientId, "This patient already exists.");
    patients[_patientId].id = _patientId;

    emit PatientAdded(_patientId);
  }

  function addDoctor() public {
    require(doctors[msg.sender].id != msg.sender, "This doctor already exists.");
    doctors[msg.sender].id = msg.sender;

    emit DoctorAdded(msg.sender);
  }

  function addNurse() public {
    require(nurses[msg.sender].id != msg.sender, "This nurse already exists.");
    nurses[msg.sender].id = msg.sender;

    emit NurseAdded(msg.sender);
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

