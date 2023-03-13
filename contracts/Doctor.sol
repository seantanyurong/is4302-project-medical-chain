pragma solidity ^0.5.0;

import "./EHR.sol";

contract Doctor {

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
    string[] patients;
    EHR[] medicalRecords;

}