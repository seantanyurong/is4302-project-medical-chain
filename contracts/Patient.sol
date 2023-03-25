pragma solidity ^0.5.0;

contract Patient {

    struct patient {
        uint256 patientId;
        address owner;
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
        mapping(address => bool) approvedDoctors;
        mapping(address => bool) approvedNurses;
        mapping(address => bool) records;
        address secondaryUser;
    }

    uint256 public numPatients = 0;
    mapping(uint256 => patient) public patients;

    // function to create patient
    function create(string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob, address _secondaryUser) public returns(uint256) {

        uint256 newPatientId = numPatients++;

        patient storage newPatient = patients[newPatientId];
        newPatient.patientId = newPatientId;
        newPatient.owner = msg.sender;
        newPatient.firstName = _firstName;
        newPatient.lastName = _lastName;
        newPatient.emailAddress = _emailAddress;
        newPatient.dob = _dob;
        newPatient.secondaryUser = _secondaryUser;

        return newPatientId;
    }

    // Modifiers

    modifier ownerOnly(uint256 patientId) {
        require(patients[patientId].owner == tx.origin);
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

    function giveDoctorAccess(uint256 patientId, address doctorAddress) public validPatientId(patientId) ownerOnly(patientId) {
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

    // Getters and setters

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

    function getSecondaryUser(uint256 patientId) public view validPatientId(patientId) ownerOnly(patientId) returns(address) {
        return patients[patientId].secondaryUser;
    }

    function setSecondaryUser(uint256 patientId, address _secondaryUser) public validPatientId(patientId) ownerOnly(patientId)  {
        patients[patientId].secondaryUser = _secondaryUser;
    }
}