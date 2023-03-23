pragma solidity ^0.5.0;

contract EHR {

    // enum EHRstate { unverified, verified }
    
    struct ehr {

        uint256 recordId;
        // EHRstate state;
        string fileName; 
        address patientAddress;
        address doctorAddress;
        uint256 timeAdded;
    }
    
    uint256 public numEHR = 0;
    mapping(uint256 => ehr) public records;

    function add(
        string memory fileName,
        address patient,
        address doctor
    ) public payable returns(uint256) {
        require(msg.value > 0.01 ether, "at least 0.01 ETH is needed"); // not sure if we need this
        
        //new EHR object
        ehr memory newEhr = ehr(
            numEHR,
            fileName,
            patient,
            doctor,
            now
        );
        
        uint256 newEhrId = numEHR++;
        records[newEhrId] = newEhr; //commit to state variable
        return newEhrId;   //return new ehrId
    }

    modifier patientOnly(uint256 ehrId) {
        require(records[ehrId].patientAddress == msg.sender);
        _;
    }
    
    modifier authorisedOnly(uint256 ehrId) {
        require(records[ehrId].patientAddress == msg.sender || records[ehrId].doctorAddress == msg.sender);
        _;
    }

    // ensure valid record ID
    modifier validEHRId(uint256 ehrId) {
        require(ehrId < numEHR);
        _;
    }

    // Getters and Setters
    function getFileName(uint256 recordId) public view returns(string memory) {
        return records[recordId].fileName;
    }

    function setFileName(uint256 recordId, string memory _fileName) public authorisedOnly(recordId) {
        records[recordId].fileName = _fileName;
    }

    function getPatientAddress(uint256 recordId) public view returns(address) {
        return records[recordId].patientAddress;
    }

    function setPatientAddress(uint256 recordId, address _patientAddress) public authorisedOnly(recordId) {
        records[recordId].patientAddress = _patientAddress;
    }

    function getDoctorAddress(uint256 recordId) public view returns(address) {
        return records[recordId].doctorAddress;
    }

    function setDoctorAddress(uint256 recordId, address _doctorAddress) public authorisedOnly(recordId) {
        records[recordId].doctorAddress = _doctorAddress;
    }

    function getTimeAdded(uint256 recordId) public view returns(uint256) {
        return records[recordId].timeAdded;
    }

    function setFileName(uint256 recordId, uint256 _timeAdded) public authorisedOnly(recordId) {
        records[recordId].timeAdded = _timeAdded;
    }
}
