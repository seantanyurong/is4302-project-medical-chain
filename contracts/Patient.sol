pragma solidity >= 0.5.0;

contract Patient {

    struct patient {
        uint256 patientId;
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
        address[] approvedPractitioners;
        address[] medicalRecords;
        address secondaryUser;
    }

    uint256 public numPatients = 0;
    mapping(uint256 => patient) public patients;

    // function to create patient
    function create(string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob, address _secondaryUser) public returns(uint256) {

        uint256 newPatientId = numPatients++;

        patient memory newPatient;
        newPatient.patientId = newPatientId;
        newPatient.firstName = _firstName;
        newPatient.lastName = _lastName;
        newPatient.emailAddress = _emailAddress;
        newPatient.secondaryUser = _secondaryUser;

        patients[newPatientId] = newPatient;
        return newPatientId;
    }

    modifier validPatientId(uint256 patientId) {
        require(patientId < numPatients);
        _;
    }

    function getFirstName(uint256 patientId) public view validPatientId(patientId) returns(string memory) {
        return patients[patientId].firstName;
    }

    function setFirstName(uint256 patientId, string memory _firstName) public validPatientId(patientId)  {
        patients[patientId].firstName = _firstName;
    }

    function getLastName(uint256 patientId) public view validPatientId(patientId) returns(string memory) {
        return patients[patientId].lastName;
    }

    function setLastName(uint256 patientId, string memory _lastName) public validPatientId(patientId)  {
        patients[patientId].lastName = _lastName;
    }

    function getEmailAddress(uint256 patientId) public view validPatientId(patientId) returns(string memory) {
        return patients[patientId].emailAddress;
    }

    function setEmailAddress(uint256 patientId, string memory _emailAddress) public validPatientId(patientId)  {
        patients[patientId].emailAddress = _emailAddress;
    }

    function getDob(uint256 patientId) public view  validPatientId(patientId) returns(string memory) {
        return patients[patientId].dob;
    }

    function setDob(uint256 patientId, string memory _dob) public validPatientId(patientId) {
        patients[patientId].dob = _dob;
    }

    function getSecondaryUser(uint256 patientId) public view validPatientId(patientId) returns(address) {
        return patients[patientId].secondaryUser;
    }

    function setSecondaryUser(uint256 patientId, address _secondaryUser) validPatientId(patientId) public {
        patients[patientId].secondaryUser = _secondaryUser;
    }
}