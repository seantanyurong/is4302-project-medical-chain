pragma solidity ^0.5.0;

contract EHR {

    enum EHRstate { unverified, verified }
    
    struct ehr {
        EHRstate state;
        address patient;
    }
    
    // mapping of all the records to their IDs
    uint256 public numEHR = 0;
    mapping(uint256 => ehr) public records;

    function add(
        address patient
    ) public payable returns(uint256) {
        require(msg.value > 0.01 ether, "at least 0.01 ETH is needed"); // not sure if we need this
        
        //new EHR object
        ehr memory newEhr = ehr(
            EHRstate.unverified,
            patient
        );
        
        uint256 newEhrId = numEHR++;
        records[newEhrId] = newEhr; //commit to state variable
        return newEhrId;   //return new diceId
    }

    //modifier to ensure a function is callable only by patient   
    modifier patientOnly(uint256 ehrId) {
        require(records[ehrId].patient == msg.sender);
        _;
    }

    // ensure valid record ID
    modifier validEHRId(uint256 ehrId) {
        require(ehrId < numEHR);
        _;
    }

}