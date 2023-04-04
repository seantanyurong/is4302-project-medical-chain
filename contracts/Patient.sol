pragma solidity ^0.5.0;

contract Patient {

    struct patient {
        uint256 patientId;
        address owner;
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
        bool approvedResearcher;
        mapping(address => bool) approvedDoctors;
        mapping(address => bool) approvedNurses;
        mapping(uint256 => bool) records;
        uint256 recordsCount;
        address secondaryUser;
    }

    uint256 public numPatients = 0;
    mapping(uint256 => patient) public patients;

    // function to create patient
    function create(string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob, bool _approvedResearcher, address _secondaryUser) public returns(uint256) {

        emit testTrigger();

        uint256 newPatientId = numPatients++;

        patient storage newPatient = patients[newPatientId];
        newPatient.patientId = newPatientId;
        newPatient.owner = msg.sender;
        newPatient.firstName = _firstName;
        newPatient.lastName = _lastName;
        newPatient.emailAddress = _emailAddress;
        newPatient.dob = _dob;
        newPatient.approvedResearcher = _approvedResearcher;
        newPatient.recordsCount = 0;
        newPatient.secondaryUser = _secondaryUser;

        emit PatientAdded(newPatient.owner);
        return newPatientId;
    }

    /********* EVENTS *********/

    event AddressDoesNotBelongToAnyPatient();
    event PatientAdded(address patientAddress);
    event GivingDoctorAccess();
    event printValue(uint256 a);
    event testTrigger();

    /********* MODIFIERS *********/

    modifier ownerOnly(uint256 patientId) {
        require(patients[patientId].owner == tx.origin);
        _;
    }

    modifier validPatientId(uint256 patientId) {
        require(patientId < numPatients);
        _;
    }


    /********* FUNCTIONS *********/

    function isValidPatientId(uint256 patientId) public view returns (bool) {
        if (patientId < numPatients) {
            return true;
        } else {
            return false;
        }
    }

    function isApprovedDoctor(uint256 patientId, address doctorAddress) public view returns (bool) {
        return patients[patientId].approvedDoctors[doctorAddress];
    }

    function isApprovedNurse(uint256 patientId, address nurseAddress) public view returns (bool) {
        return patients[patientId].approvedNurses[nurseAddress];
    }

    // Loop through existing senders to check if address is a sender
    function isSender(address owner) public view returns(bool) {
        for (uint i = 0; i < numPatients; i++) {
            patient storage temp = patients[i];
            if (temp.owner == owner) {
                return true;
            }
        }

        return false;
    }

    // Populate this logic here
    function getResearchPatients() public view returns (uint256[] memory) {

        uint256 size = 0;

        // Get size since array size not mutable
        for (uint i = 0; i < numPatients; i++) {
            if (patients[i].approvedResearcher) {
                size++;
            }
        }

        uint256[] memory result = new uint256[](size);
        uint256 count = 0;

        // Loop through patients and feed approved into array
        for (uint i = 0; i < numPatients; i++) {
            if (patients[i].approvedResearcher) {
                result[count] = i;
                count++;
            }
        }
        return result;
    }

    // Patient verify record
    function signOffRecord(uint256 patientId, uint256 recordId) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].records[recordId] = true;
        patients[patientId].recordsCount++;
    }

    // get patient's id from their address (used in medicalChain patientAcknowledgeRecord function)
    function getPatientIdFromPatientAddress(address patientAddress) public returns (uint256) {
        for (uint i = 0; i < numPatients; i++) {
            if (patients[i].owner == patientAddress) {
                emit printValue(i);
                return i;
                
            }
        }
        emit AddressDoesNotBelongToAnyPatient();
    }

    // checked the record is acknowledged by patient
    function isRecordAcknowledged(uint256 patientId, uint256 recordId) public view validPatientId(patientId) ownerOnly(patientId) returns(bool) {
        return patients[patientId].records[recordId];
    }

    function giveDoctorAccess(uint256 patientId, address doctorAddress) public validPatientId(patientId) ownerOnly(patientId) {
        // emit GivingDoctorAccess();
        patients[patientId].approvedDoctors[doctorAddress] = true;
    }

    function removeDoctorAccess(uint256 patientId, address doctorAddress) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].approvedDoctors[doctorAddress] = false;
    }

    function giveNurseAccess(uint256 patientId, address nurseAddress) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].approvedNurses[nurseAddress] = true;
    }

    function removeNurseAccess(uint256 patientId, address nurseAddress) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].approvedNurses[nurseAddress] = false;
    }

    function addEhr(uint256 patientId, uint256 recordId) public validPatientId(patientId) {
        patients[patientId].records[recordId] = true;
    }


    /********* GETTERS & SETTERS *********/

    function getFirstName(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(string memory) {
        return patients[patientId].firstName;
    }

    function setFirstName(uint256 patientId, string memory _firstName) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].firstName = _firstName;
    }

    function getLastName(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(string memory) {
        return patients[patientId].lastName;
    }

    function setLastName(uint256 patientId, string memory _lastName) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].lastName = _lastName;
    }

    function getEmailAddress(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(string memory) {
        // emit testTrigger();
        return patients[patientId].emailAddress;
    }

    function setEmailAddress(uint256 patientId, string memory _emailAddress) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].emailAddress = _emailAddress;
    }

    function getDob(uint256 patientId) public view  validPatientId(patientId) ownerOnly(patientId) returns(string memory) {
        return patients[patientId].dob;
    }

    function setDob(uint256 patientId, string memory _dob) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].dob = _dob;
    }

    function isDoctorApproved(uint256 patientId, address doctorAddress) public view returns(bool) {
        return patients[patientId].approvedDoctors[doctorAddress];
    }

    function isNurseApproved(uint256 patientId, address nurseAddress) public view returns(bool) {
        return patients[patientId].approvedNurses[nurseAddress];
    }

    function getApprovedReseacher(uint256 patientId) public view  validPatientId(patientId) ownerOnly(patientId) returns(bool) {
        return patients[patientId].approvedResearcher;
    }

    function setApprovedResearcher(uint256 patientId, bool _approvedResearcher) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].approvedResearcher = _approvedResearcher;
    }

    function getRecordsCount(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(uint256) {
        return patients[patientId].recordsCount;
    }
    
    function setRecordsCount(uint256 patientId, uint256 _recordsCount) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].recordsCount = _recordsCount;
    }

    function getSecondaryUser(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(address) {
        return patients[patientId].secondaryUser;
    }

    function setSecondaryUser(uint256 patientId, address _secondaryUser) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].secondaryUser = _secondaryUser;
    }

    function getData(uint256 patientId) public view returns(uint256 id,
        string memory firstName,
        string memory lastName,
        string memory emailAddress,
        string memory dob) {
        return (patients[patientId].patientId, patients[patientId].firstName, patients[patientId].lastName, patients[patientId].emailAddress, patients[patientId].dob);
    }

    function getPatientAddress(uint256 patientId) public view validPatientId(patientId) returns(address) {
        return patients[patientId].owner;
    }
}