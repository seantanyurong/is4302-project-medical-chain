pragma solidity ^0.5.0;

contract EHR {

    // enum EHRstate { unverified, verified }
    enum RecordType{ IMMUNISATION, ALLERGIES, LABORATORY_RESULTS, SCREENING_RECORDS, DISCHARGE_INFORMATION, VITAL_HEALTH_TRACKING, APPOINTMENT_INFORMATION, MEDICATIONS}
    
    struct ehr {

        uint256 recordId;
        RecordType recordType;
        // EHRstate state;
        string fileName; 
        address patientAddress;
        address doctorAddress;
        uint256 timeAdded;
    }
    
    uint256 public numEHR = 0;
    mapping(uint256 => ehr) public records;
    // record type -> (record type id -> records)

    function add(
        RecordType recordType,
        string memory fileName,
        address patient,
        address doctor
    ) public payable returns(uint256) {
        require(msg.value > 0.01 ether, "at least 0.01 ETH is needed"); // not sure if we need this
        
        //new EHR object
        ehr memory newEhr = ehr(
            numEHR,
            recordType,
            fileName,
            patient,
            doctor,
            now
        );
        
        uint256 newEhrId = numEHR++;
        records[newEhrId] = newEhr; //commit to state variable
        return newEhrId;   //return new ehrId
    }


    /********* MODIFIERS *********/

    modifier patientOnly(uint256 ehrId) {
        require(records[ehrId].patientAddress == msg.sender);
        _;
    }

    // ensure valid record ID
    modifier validEHRId(uint256 ehrId) {
        require(ehrId < numEHR);
        _;
    }


    /********* FUNCTIONS *********/

    function getDoctorAddress(uint256 recordId) public view returns(address) {
        return records[recordId].doctorAddress;
    }

    function getPatientAddress(uint256 recordId) public view returns(address) {
        return records[recordId].patientAddress;
    }

    function getRecord(uint256 recordId) public view returns(uint256 id,
        RecordType recordType,
        string memory fileName,
        address patientAddress,
        address doctorAddress,
        uint256 timeAdded) {
        return (records[recordId].recordId, records[recordId].recordType, records[recordId].fileName, records[recordId].patientAddress, records[recordId].doctorAddress, records[recordId].timeAdded);
    }

    function updateRecord(uint256 recordId, RecordType recordType, string memory fileName) public {
        // Patient & Doctor address and timeAdded should not be editable
        records[recordId].recordType = recordType;
        records[recordId].fileName = fileName;
    }


    function isRecordBelongToPatient(uint256 recordId, address _patientAddress) public view returns(bool) {
        if (records[recordId].patientAddress == _patientAddress) {
            return true;
        } else {
            return false;
        }
    }

    function doesRecordMatchRecordType(uint256 recordId, RecordType _recordType) public view returns(bool) {
        if(records[recordId].recordType == _recordType) {
            return true;
        } else {
            return false;
        }
    }
}
