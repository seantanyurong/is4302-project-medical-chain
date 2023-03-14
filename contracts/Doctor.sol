pragma solidity ^0.5.0;

import "./EHR.sol";

contract Doctor {

    address owner;
    uint256 doctorId;
    string firstName;
    string lastName;
    string emailAddress;
    string dob;
    address[] qualifications;
 
    address[] patients;
    EHR[] medicalRecords;

    function getPatients() public view returns (address[] memory) {
        return patients;
    }

    function addPatient(address patient) public {
        patients.push(patient);
    }

    function getEHRs() public view returns (EHR[] memory) {
        return medicalRecords;
    }

    function addEHR(EHR medicalRecord) public {
        medicalRecords.push(medicalRecord);
    }

    // Getters and Setters

    function getDoctorId() public view returns(uint256) {
        return doctorId;
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

    function getQualifications() public view returns (address[] memory) {
        return qualifications;
    }

    function addQualification(address _qualification) public {
        qualifications.push(_qualification);
    }

    // Updating

    function updateFirstName(string memory newFirstName) public {
        require(msg.sender == owner, "This doctor record does not belong to you!");
        setFirstName(newFirstName);
    }

    function updateLastName(string memory newLastName) public {
        require(msg.sender == owner, "This doctor record does not belong to you!");
        setLastName(newLastName);
    }

    function updateEmailAddress(string memory newEmailAddress) public {
        require(msg.sender == owner, "This doctor record does not belong to you!");
        setEmailAddress(newEmailAddress);
    }

    function updateDOB(string memory newDOB) public {
        require(msg.sender == owner, "This doctor record does not belong to you!");
        setDob(newDOB);
    }
}