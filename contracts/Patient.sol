pragma solidity >= 0.5.0;

contract Patient {

    struct patient {
        uint256 patientId;
        address owner;
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
        mapping(uint256 => bool) approvedDoctors;
        mapping(uint256 => bool) approvedNurses;
        mapping(uint256 => bool) records;
    }

    uint256 public numPatients = 0;
    mapping(uint256 => patient) public patients;
    mapping(uint256 => address) secondaryUser;
    

    // function to create patient
    function create(string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob, address _secondaryUser) public returns(uint256) {

        uint256 newPatientId = numPatients++;

        patient memory newPatient;
        newPatient.patientId = newPatientId;
        newPatient.owner = msg.sender;
        newPatient.firstName = _firstName;
        newPatient.lastName = _lastName;
        newPatient.emailAddress = _emailAddress;
        newPatient.dob = _dob;

        patients[newPatientId] = newPatient;
        secondaryUser[newPatientId] = _secondaryUser;
        return newPatientId;
    }

    // Modifiers

    modifier ownerOnly(uint256 patientId) {
        require(patients[patientId].owner == tx.origin);
        _;
    }

    modifier approvedOnly(uint256 patientId) {
        require(patients[patientId].owner == tx.origin || secondaryUser[patientId] == tx.origin);
        _;
    }

    modifier validPatientId(uint256 patientId) {
        require(patientId < numPatients);
        _;
    }

    // Functions

    // function patientExists(uint256 patientId) public view validPatientId(patientId) returns(bool) {
    //     return patientId < numPatients;
    // }

    // function senderIsPatient(uint256 patientId) public view validPatientId(patientId) returns(bool) {
    //     return patients[patientId].owner == tx.origin;
    // }

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

    function giveDoctorAccess(uint256 patientId, uint256 doctorId) public validPatientId(patientId) approvedOnly(patientId) {
        patients[patientId].approvedDoctors[doctorId] = true;
    }

    function removeDoctorAccess(uint256 patientId, uint256 doctorId) public validPatientId(patientId) approvedOnly(patientId) {
        patients[patientId].approvedDoctors[doctorId] = false;
    }

    function giveNurseAccess(uint256 patientId, uint256 nurseId) public validPatientId(patientId) approvedOnly(patientId) {
        patients[patientId].approvedNurses[nurseId] = true;
    }

    function removeNurseAccess(uint256 patientId, uint256 nurseId) public validPatientId(patientId) approvedOnly(patientId) {
        patients[patientId].approvedNurses[nurseId] = false;
    }

    // Getters and setters

    function getFirstName(uint256 patientId) public view validPatientId(patientId) approvedOnly(patientId) returns(string memory) {
        return patients[patientId].firstName;
    }

    function setFirstName(uint256 patientId, string memory _firstName) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].firstName = _firstName;
    }

    function getLastName(uint256 patientId) public view validPatientId(patientId) approvedOnly(patientId) returns(string memory) {
        return patients[patientId].lastName;
    }

    function setLastName(uint256 patientId, string memory _lastName) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].lastName = _lastName;
    }

    function getEmailAddress(uint256 patientId) public view validPatientId(patientId) approvedOnly(patientId) returns(string memory) {
        return patients[patientId].emailAddress;
    }

    function setEmailAddress(uint256 patientId, string memory _emailAddress) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].emailAddress = _emailAddress;
    }

    function getDob(uint256 patientId) public view  validPatientId(patientId) approvedOnly(patientId) returns(string memory) {
        return patients[patientId].dob;
    }

    function setDob(uint256 patientId, string memory _dob) public validPatientId(patientId) ownerOnly(patientId) {
        patients[patientId].dob = _dob;
    }

    function getSecondaryUser(uint256 patientId) public view validPatientId(patientId) approvedOnly(patientId) returns(address) {
        return secondaryUser[patientId];
    }

    function setSecondaryUser(uint256 patientId, address _secondaryUser) public validPatientId(patientId) ownerOnly(patientId)  {
        secondaryUser[patientId] = _secondaryUser;
    }
}