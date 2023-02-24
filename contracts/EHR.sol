pragma solidity ^0.5.0;

contract EHR {

    enum EHRstate { unverified, verified }
    
    struct ehr {
        EHRstate state;
        address patient;
    }
    
    mapping(uint256 => ehr) public records;

}
