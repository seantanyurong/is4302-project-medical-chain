pragma solidity ^0.5.0;

import "./EHR.sol";

contract Nurse {

    struct location {
        string number;
        string street;
        string city;
        string country;
        string postalCode;
    }

    struct PublicProfile {
        string firstName;
        string lastName;
        string emailAddress;
        string dob;
        location locationAddress;
        address[] qualifications;
        string imageUrl;
    }

    uint256 practitionerId;
    PublicProfile publicProfile;
    address[] patients;
    EHR[] medicalRecords;

    function addPatient(address patient) public {
        patients.push(patient);
    }

}