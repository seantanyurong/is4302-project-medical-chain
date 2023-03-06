pragma solidity >= 0.5.0;

contract Patient {

    address owner;
    uint256 patientId;
    string firstName;
    string lastName;
    string emailAddress;
    string dob;
    address[] approvedPractitioners;
    address[] medicalRecords;
    address secondaryUser;


    // ID should be autogenerated. Have some increment counter
    constructor(uint256 _patientId, string memory _firstName, string memory _lastName, string memory _emailAddress, string memory _dob, address _secondaryUser) public {
        owner = msg.sender;
        patientId = _patientId;
        firstName = _firstName;
        lastName = _lastName;
        emailAddress = _emailAddress;
        dob = _dob;
        secondaryUser = _secondaryUser;
    }

    function getPatientId() public view returns(uint256) {
        return patientId;
    }

    function getFirstName() public view returns(string memory) {
        return firstName;
    }

    function setFirstName(string memory _firstName) public {
        firstName = _firstName;
    }

    function getLastName() public view returns(string memory) {
        return firstName;
    }

    function setLastName(string memory _lastName) public {
        lastName = _lastName;
    }

    function getEmailAddress() public view returns(string memory) {
        return firstName;
    }

    function setEmailAddress(string memory _emailAddress) public {
        emailAddress = _emailAddress;
    }

    function getDob() public view returns(string memory) {
        return firstName;
    }

    function setDob(string memory _dob) public {
        dob = _dob;
    }

    function getSecondaryUser() public view returns(address) {
        return secondaryUser;
    }

    function setSecondaryUser(address _secondaryUser) public {
        secondaryUser = _secondaryUser;
    }
}