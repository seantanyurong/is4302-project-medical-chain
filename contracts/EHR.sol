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

    //function to create a new dice, and add to 'dices' map. requires at least 0.01ETH to create
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
}
