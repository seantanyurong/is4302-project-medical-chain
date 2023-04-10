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
        bool patientSignedOff;
    }
    
    uint256 public numEHR = 0;
    mapping(uint256 => ehr) public records;
    // record type -> (record type id -> records)

    function add(
        RecordType recordType,
        string memory fileName,
        address patient,
        address practitioner
    ) public returns(uint256) {
        
        //new EHR object
        ehr memory newEhr = ehr(
            numEHR,
            recordType,
            fileName,
            patient,
            practitioner,
            now,
            false
        );
        
        uint256 newEhrId = numEHR++;
        records[newEhrId] = newEhr; //commit to state variable
        emit EHRAdded(newEhr.doctorAddress);
        return newEhrId;   //return new ehrId
    }

    /********* EVENTS *********/

    event EHRAdded(address ehrAddress);

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

    function isValidRecordId(uint256 recordId) public view returns (bool) {
        if (recordId < numEHR) {
            return true;
        } else {
            return false;
        }
    }

    function getRecord(uint256 recordId) public view returns(uint256 id,
        RecordType recordType,
        string memory fileName,
        address patientAddress,
        address doctorAddress,
        uint256 timeAdded,
        bool patientSignedOff) {
        return (recordId, getRecordType(recordId), getRecordFileName(recordId), getRecordPatientAddress(recordId), getRecordDoctorAddress(recordId), getRecordTimeAdded(recordId), getRecordPatientSignedOff(recordId));
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

    function doesRecordMatchDoctorAddress(uint256 recordId, address doctorAddress) public view returns(bool) {
        if(records[recordId].doctorAddress == doctorAddress) {
            return true;
        } else {
            return false;
        }
    }

    function patientSignOff(uint256 recordId) public {
        records[recordId].patientSignedOff = true;
    }

    /********* GETTERS & SETTERS *********/
    
    function getRecordType(uint256 recordId) public view returns(RecordType) {
        return records[recordId].recordType;
    }

    function getRecordFileName(uint256 recordId) public view returns(string memory) {
        return records[recordId].fileName;
    }

    function getRecordPatientAddress(uint256 recordId) public view returns(address) {
        return records[recordId].patientAddress;
    }

    function getRecordDoctorAddress(uint256 recordId) public view returns(address) {
        return records[recordId].doctorAddress;
    }

    function getRecordTimeAdded(uint256 recordId) public view returns(uint256) {
        return records[recordId].timeAdded;
    }

    function getRecordPatientSignedOff(uint256 recordId) public view returns(bool) {
        return records[recordId].patientSignedOff;
    }

}
