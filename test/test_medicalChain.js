const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

var Doctor = artifacts.require("../contracts/Doctor.sol");
var EHR = artifacts.require("../contracts/EHR.sol");
var MedicalChainPatient = artifacts.require(
  "../contracts/medicalChainPatient.sol"
);
var MedicalChainStaff = artifacts.require("../contracts/medicalChainStaff.sol");
var Nurse = artifacts.require("../contracts/Nurse.sol");
var Patient = artifacts.require("../contracts/Patient.sol");
var Researcher = artifacts.require("../contracts/Researcher.sol");

// Account roles used for testing
// account[2]: patient
// account[3]: secondary user (patient)
// account[4]: doctor
// account[5]: nurse
// account[6]: researcher
// account[7]: patient
// account[8]: doctor

/************************************ Testing for creation ************************************/
/************************************ Testing for creation ************************************/
/************************************ Testing for creation ************************************/
/************************************ Testing for creation ************************************/
/************************************ Testing for creation ************************************/

contract("Testing for creation", function (accounts) {
  before(async () => {
    doctorInstance = await Doctor.deployed();
    ehrInstance = await EHR.deployed();
    medicalChainPatientInstance = await MedicalChainPatient.deployed();
    medicalChainStaffInstance = await MedicalChainStaff.deployed();
    nurseInstance = await Nurse.deployed();
    patientInstance = await Patient.deployed();
    researcherInstance = await Researcher.deployed();
  });

  console.log("Testing Begins: Testing for creation");

  it("Test if medical chains exists", async () => {
    // test medicalChainPatient exists
    let testingTest1 = await medicalChainPatientInstance.testingTest(10, {
      from: accounts[1],
    });
    truffleAssert.eventEmitted(testingTest1, "testEvent");

    // test medicalChainStaff exists
    let testingTest2 = await medicalChainStaffInstance.testingTest(10, {
      from: accounts[1],
    });
    truffleAssert.eventEmitted(testingTest2, "testEvent");
  });

  it("Test if patient created and email can be fetched", async () => {
    // Test: Test if creating a patient that indicate an secondary user address that is not a patient will revert
    // Outcome: Revert success
    await truffleAssert.reverts(
      patientInstance.create(
        "Shawn",
        "Tan",
        "shawntan@gmail.com",
        "18/04/2000",
        true,
        accounts[3],
        {
          from: accounts[2],
        }
      ),
      "Secondary user not registered!"
    );

    // Create a patient using accounts[2] address
    let newPatient = await patientInstance.create(
      "Shawn",
      "Tan",
      "shawntan@gmail.com",
      "18/04/2000",
      true,
      "0x0000000000000000000000000000000000000000",
      {
        from: accounts[2],
      }
    );

    // PatientAdded event emitted for successful creation of patient
    truffleAssert.eventEmitted(newPatient, "PatientAdded");

    // Test: Test if creating a duplicate patient using same address (accounts[2]) will revert
    // Outcome: Revert success
    await truffleAssert.reverts(
      patientInstance.create(
        "Shawn",
        "Tan",
        "shawntan@gmail.com",
        "18/04/2000",
        true,
        accounts[3],
        {
          from: accounts[2],
        }
      ),
      "Patient already registered!"
    );

    // Test: Test if patient is properly created and not undefined
    // Outcome: Correct
    await assert.notStrictEqual(
      newPatient,
      undefined,
      "Failed to create patient"
    );

    // Test: Test if getting email address using invalid patient id will revert
    // Outcome: Revert success
    await truffleAssert.reverts(
      patientInstance.getEmailAddress(2, {
        from: accounts[2],
      }),
      "Invalid patient Id!"
    );

    // Retrieve email from patient id 0
    let email = await patientInstance.getEmailAddress(0, {
      from: accounts[2],
    });

    // Test: Test if email retrieved matches the email of patient id 0
    // Outcome: Correct
    await assert.strictEqual(
      email,
      "shawntan@gmail.com",
      "email does not match!"
    );
  });

  it("Test if doctor created", async () => {
    // Create a doctor using accounts[4] address
    let newDoctor = await doctorInstance.create(
      "Gary",
      "Tay",
      "garytay@gmail.com",
      "20/01/1980",
      {
        from: accounts[4],
      }
    );

    // DoctorAdded event emitted for successful creation of doctor
    truffleAssert.eventEmitted(newDoctor, "DoctorAdded");

    // Test: Test if doctor is properly created and not undefined
    // Outcome: Correct
    await assert.notStrictEqual(
      newDoctor,
      undefined,
      "Failed to create doctor"
    );
  });

  it("Test if EHR created", async () => {
    // Creating an EHR record for patient id 0 (accounts[2]) issued by doctor id 0 (accounts[4])
    let newEHR = await ehrInstance.add(
      EHR.RecordType.IMMUNISATION,
      "Immunisation Records",
      accounts[2],
      accounts[4],
      {
        from: accounts[4],
      }
    );

    // EHRAdded event emitted for successful creation of EHR
    truffleAssert.eventEmitted(newEHR, "EHRAdded");

    // Test: Test if EHR is properly created and not undefined
    // Outcome: Correct
    await assert.notStrictEqual(newEHR, undefined, "Failed to create EHR");
  });

  it("Test query of RecordType matches", async () => {
    // Retrieve bool if EHR record id 0 RecordType is IMMUNISATION
    let recordMatchResult = await ehrInstance.doesRecordMatchRecordType(
      0,
      EHR.RecordType.IMMUNISATION
    );

    // Test: Test if EHR record id 0 Record Type is fetched correctly
    // Outcome: Correct
    await assert.strictEqual(
      recordMatchResult,
      true,
      "EHR type does not match!"
    );
  });

  it("Test if nurse created", async () => {
    // Creating a Nurse using accounts[5] address
    let newNurse = await nurseInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[5],
      }
    );

    // NurseAdded event emitted for successful creation of nurse
    truffleAssert.eventEmitted(newNurse, "NurseAdded");

    // Test: Test if nurse is properly created and not undefined
    // Outcome: Correct
    await assert.notStrictEqual(newNurse, undefined, "Failed to create nurse");
  });

  it("Test if researcher created", async () => {
    // Creating a Researcher using accounts[6] address
    let newResearcher = await researcherInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[6],
      }
    );

    // ResearcherAdded event emitted for successful creation of Researcher
    truffleAssert.eventEmitted(newResearcher, "ResearcherAdded");

    // Test: Test if reseacher is properly created and not undefined
    // Outcome: Correct
    await assert.notStrictEqual(
      newResearcher,
      undefined,
      "Failed to create researcher"
    );
  });

  it("Test if able to get patient id from address", async () => {
    // Retrieve patient id given address of patient id 0
    let patientId = await patientInstance.getPatientIdFromPatientAddress(
      accounts[2],
      {
        from: accounts[2],
      }
    );

    // Test: Test if patient id retrieved matches patient id 0 (accounts[2])
    // Outcome: Correct
    await assert.strictEqual(
      patientId["words"][0],
      0,
      "Patient ID does not match!"
    );

    // Creating a new patient using accounts[7] address with valid secondaryUser address
    let newPatient2 = await patientInstance.create(
      "Gavin",
      "Koh",
      "gavinkoh@gmail.com",
      "28/09/2000",
      true,
      accounts[2],
      {
        from: accounts[7],
      }
    );

    // Retrieve patient id given address of patient id 1
    let secondPatientId = await patientInstance.getPatientIdFromPatientAddress(
      accounts[7],
      {
        from: accounts[7],
      }
    );

    // Test: Test if patient id retrieved matches patient id 1 (accounts[7])
    // Outcome: Correct
    await assert.strictEqual(
      secondPatientId["words"][0],
      1,
      "Patient ID does not match!"
    );
  });
});

// /************************************ Testing for EHR interaction ************************************/
// /************************************ Testing for EHR interaction ************************************/
// /************************************ Testing for EHR interaction ************************************/
// /************************************ Testing for EHR interaction ************************************/
// /************************************ Testing for EHR interaction ************************************/

contract("Testing for EHR interaction", function (accounts) {
  before(async () => {
    doctorInstance = await Doctor.deployed();
    ehrInstance = await EHR.deployed();
    medicalChainPatientInstance = await MedicalChainPatient.deployed();
    medicalChainStaffInstance = await MedicalChainStaff.deployed();
    nurseInstance = await Nurse.deployed();
    patientInstance = await Patient.deployed();
    researcherInstance = await Researcher.deployed();
  });

  console.log("Testing begins: Testing for EHR interaction");

  it("Test EHR adding", async () => {
    // Creating a Patient using accounts[2] address
    let newPatient = await patientInstance.create(
      "Shawn",
      "Tan",
      "shawntan@gmail.com",
      "18/04/2000",
      true,
      "0x0000000000000000000000000000000000000000",
      {
        from: accounts[2],
      }
    );

    // Creating a Doctor using accounts[4] address
    let newDoctor = await doctorInstance.create(
      "Gary",
      "Tay",
      "garytay@gmail.com",
      "20/01/1980",
      {
        from: accounts[4],
      }
    );

    // Test: Test if patient giving access to a invalid doctor address reverts
    // Outcome: Revert successful
    await truffleAssert.reverts(
      medicalChainPatientInstance.giveDoctorAccess(0, accounts[8], {
        from: accounts[2],
      }),
      "Doctor address given is not valid"
    );

    // Patient id 0 grant doctor id 0 access
    let givingDoctorAccess = await medicalChainPatientInstance.giveDoctorAccess(
      0,
      accounts[4],
      {
        from: accounts[2],
      }
    );

    // Doctor id 0 register patient id 0
    let registeringPatient =
      await medicalChainStaffInstance.registerPatientWithDoctor(0, 0, {
        from: accounts[4],
      });

    // Retrieve patient id 0 records count
    let recordsCount0 = await patientInstance.getRecordsCount(0, {
      from: accounts[2],
    });

    // Test: Test if records count retrieved is 0 as no record has been issued to patient id 0 yet
    // Outcome: Correct
    await assert.strictEqual(
      recordsCount0.words[0],
      0,
      "Initial count does not match"
    );

    // Doctor id 0 issue EHR record to patient id 0
    let addingEHR = await medicalChainStaffInstance.addNewEHR(
      EHR.RecordType.IMMUNISATION,
      0,
      "Immunisation Records",
      {
        from: accounts[4],
      }
    );

    // AddingEHR event emitted for doctor successfully issuing EHR record to patient
    truffleAssert.eventEmitted(addingEHR, "AddingEHR");

    // Retrieve patient id 0 records count
    let recordsCount1 = await patientInstance.getRecordsCount(0, {
      from: accounts[2],
    });

    // Test: Test if records count retrieved is 1 as 1 record has been issued to patient id 0 by doctor id 0
    // Outcome: Correct
    await assert.strictEqual(
      recordsCount1.words[0],
      1,
      "Record count does not match"
    );
  });

  it("Test EHR removing", async () => {
    // Retrieve patient id 0 records count
    let recordsCount1 = await patientInstance.getRecordsCount(0, {
      from: accounts[2],
    });

    // Test: Test if records count retrieved is 1 as 1 record has been issued to patient id 0 by doctor id 0
    // Outcome: Correct
    await assert.strictEqual(
      recordsCount1.words[0],
      1,
      "Record count does not match"
    );

    // Creating a Patient (id: 1) using accounts[7] address
    let newPatient2 = await patientInstance.create(
      "Steven",
      "Tio",
      "steventio@gmail.com",
      "18/04/2000",
      true,
      "0x0000000000000000000000000000000000000000",
      {
        from: accounts[7],
      }
    );

    // Creating a Doctor (id: 1) using accounts[4] address
    let newDoctor2 = await doctorInstance.create(
      "Gary",
      "Tay",
      "garytay@gmail.com",
      "20/01/1980",
      {
        from: accounts[8],
      }
    );

    // Patient id 1 grant doctor id 1 access
    let givingDoctorAccess2 =
      await medicalChainPatientInstance.giveDoctorAccess(1, accounts[8], {
        from: accounts[7],
      });

    // Doctor id 1 register patient id 1
    let registeringPatient =
      await medicalChainStaffInstance.registerPatientWithDoctor(1, 1, {
        from: accounts[8],
      });

    // Doctor id 1 issue EHR record to patient id 1
    let addingEHR2 = await medicalChainStaffInstance.addNewEHR(
      EHR.RecordType.IMMUNISATION,
      1,
      "Immunisation Records",
      {
        from: accounts[8],
      }
    );

    // Test: Test if doctor id 0 can remove EHR of patient id 1 (Doctor not in patient's approved list)
    // Outcome: Correct, doctor unable to remove
    await truffleAssert.reverts(
      medicalChainStaffInstance.removeEHR(1, 1, {
        from: accounts[4],
      }),
      "Doctor is not in patient's list of approved doctors"
    );

    // Doctor id 0 remove EHR record id 0 from patient id 0
    let removingEHR = await medicalChainStaffInstance.removeEHR(0, 0, {
      from: accounts[4],
    });

    // RemovingEHR event emitted for successful removal of EHR
    truffleAssert.eventEmitted(removingEHR, "RemovingEHR");

    // Retrieve patient id 0 records count
    let recordsCount0 = await patientInstance.getRecordsCount(0, {
      from: accounts[2],
    });

    // Test: Test if patient id 0's record counts is 0
    // Outcome: Correct
    await assert.strictEqual(
      recordsCount0.words[0],
      0,
      "Post count does not match"
    );
  });

  it("Test EHR acknowledging", async () => {
    // Doctor id 0 issue EHR record (id: 2) to patient id 0
    let addingEHR3 = await medicalChainStaffInstance.addNewEHR(
      EHR.RecordType.IMMUNISATION,
      0,
      "Chicken Pox Immunisation",
      {
        from: accounts[4],
      }
    );

    // Test: Test if patient can acknowledge other patient's record
    // Outcome: Correct, patient unable to knowledge
    truffleAssert.reverts(
      medicalChainPatientInstance.patientAcknowledgeRecord(0, {
        from: accounts[7],
      }),
      "Record does not belong to this patient"
    );

    // Test: Test if non patient can acknowledge a record
    // Outcome: Correct, non patient unable to knowledge
    await truffleAssert.reverts(
      medicalChainPatientInstance.patientAcknowledgeRecord(1, {
        from: accounts[4],
      }),
      "This person is not a patient!"
    );

    // Patient id 0 acknowledges EHR record id 2
    let patientSigningRecord =
      await medicalChainPatientInstance.patientAcknowledgeRecord(2, {
        from: accounts[2],
      });

    // AcknowledgingRecord event emitted for successful acknowledging of record
    truffleAssert.eventEmitted(patientSigningRecord, "AcknowledgingRecord");

    // Retrieve patient id 0's acknowledged record count
    let patientAcknowledgeRecordCount =
      await patientInstance.getAcknowledgedRecordsCount(0, {
        from: accounts[2],
      });

    // Test: Test that patient id 0's acknowledged record count is 1
    // Outcome: Correct
    await assert.strictEqual(
      patientAcknowledgeRecordCount.words[0],
      1,
      "Acknowledge record count does not match"
    );

    // Retrieve the bool status whether record id 2 is acknowledged
    let recordSignedOff = await ehrInstance.getRecordPatientSignedOff(2, {
      from: accounts[2],
    });

    // Test: Test if record id 2 is acknowledged
    // Outcome: Correct
    await assert.ok(recordSignedOff, "Record has not been signed off");
  });

  it("Test EHR updating", async () => {
    // Retrieve EHR record id 0's information using approved doctor id 0 (accounts[4])
    let beforeUpdate =
      await medicalChainStaffInstance.practitionerViewRecordByRecordID(0, 0, {
        from: accounts[4],
      });

    // Test: Test that EHR record id 0's file name before update is Immunisation Records
    // Outcome: Correct
    assert.strictEqual(
      beforeUpdate["fileName"] == "Immunisation Records",
      true,
      "Incorrect record chosen!"
    );

    // Test: Test if email retrieved matches the email of patient id 0
    // Outcome: Correct
    await truffleAssert.reverts(
      medicalChainStaffInstance.updateRecordByRecordId(
        0,
        0,
        EHR.RecordType.LABORATORY_RESULTS,
        "Laboratory Results",
        { from: accounts[2] }
      ),
      "User is not a doctor!"
    );

    // Test: Test if doctor id 1 that is not the issuer can update EHR record id 0 belonging to patient id 0
    // Outcome: Correct, doctor unable to update
    await truffleAssert.reverts(
      medicalChainStaffInstance.updateRecordByRecordId(
        0,
        0,
        EHR.RecordType.LABORATORY_RESULTS,
        "Laboratory Results",
        { from: accounts[8] }
      ),
      "Doctor is not issuer!"
    );

    // Doctor id 0 update EHR record id 0 belonging to patient id 0
    let updateRecord = await medicalChainStaffInstance.updateRecordByRecordId(
      0,
      0,
      EHR.RecordType.LABORATORY_RESULTS,
      "Laboratory Results",
      { from: accounts[4] }
    );

    // Retrieve EHR record id 0's information using approved doctor id 0 (accounts[4])
    let afterUpdate =
      await medicalChainStaffInstance.practitionerViewRecordByRecordID(0, 0, {
        from: accounts[4],
      });

    /// Test: Test that EHR record id 0's file name after update is Laboratory Results
    // Outcome: Correct
    assert.strictEqual(
      afterUpdate["fileName"] == "Laboratory Results",
      true,
      "Update failed!"
    );
  });
});

/************************************ Testing for practitioner's and researcher's access ************************************/
/************************************ Testing for practitioner's and researcher's access ************************************/
/************************************ Testing for practitioner's and researcher's access ************************************/
/************************************ Testing for practitioner's and researcher's access ************************************/
/************************************ Testing for practitioner's and researcher's access ************************************/
contract("Testing for practitioner's and researcher's access", function (accounts) {
  before(async () => {
    doctorInstance = await Doctor.deployed();
    ehrInstance = await EHR.deployed();
    medicalChainPatientInstance = await MedicalChainPatient.deployed();
    medicalChainStaffInstance = await MedicalChainStaff.deployed();
    nurseInstance = await Nurse.deployed();
    patientInstance = await Patient.deployed();
    researcherInstance = await Researcher.deployed();
  });

  console.log("Testing begins: Testing for practitioner's and researcher's access");

  it("Test if adding and removing doctor's access works", async () => {
    // Creating a Patient (id:0) using accounts[2] address
    let newPatient = await patientInstance.create(
      "Shawn",
      "Tan",
      "shawntan@gmail.com",
      "18/04/2000",
      true,
      "0x0000000000000000000000000000000000000000",
      {
        from: accounts[2],
      }
    );

    // Creating a Patient (id:1) using accounts[7] address
    let newPatient2 = await patientInstance.create(
      "Katie",
      "Tan",
      "katietan@gmail.com",
      "21/04/2000",
      true,
      "0x0000000000000000000000000000000000000000",
      {
        from: accounts[7],
      }
    );

    // Creating a Doctor (id: 0) using accounts[4] address
    let newDoctor = await doctorInstance.create(
      "Gary",
      "Tay",
      "garytay@gmail.com",
      "20/01/1980",
      {
        from: accounts[4],
      }
    );

    // Test: Test if non patient can call this function for patient id 0
    // Outcome: Correct, unable to call
    await truffleAssert.reverts(
      medicalChainPatientInstance.giveDoctorAccess(0, accounts[4], {
        from: accounts[4],
      }),
      "This person is not a patient!"
    );

    // Test: Test if other patient can call this function for patient id 0
    // Outcome: Correct, unable to call
    await truffleAssert.reverts(
      medicalChainPatientInstance.giveDoctorAccess(0, accounts[4], {
        from: accounts[7],
      }),
      "This patient is not allowed to call on behalf of other patient"
    );

    // Grant doctor id 0 access to patient id 0
    let givingDoctorAccess = await medicalChainPatientInstance.giveDoctorAccess(
      0,
      accounts[4],
      {
        from: accounts[2],
      }
    );

    // GivingDoctorAccess event emitted for successful giving access to doctor
    truffleAssert.eventEmitted(givingDoctorAccess, "GivingDoctorAccess");

    // Retrieve bool condition whether doctor id 0 is approved in patient id 0's approved doctors
    let doctorAccess = await patientInstance.isDoctorApproved(0, accounts[4], {
      from: accounts[2],
    });

    // Test: Test if doctor id 0 has access to patient id 0
    // Outcome: Correct, able to access
    await assert.ok(doctorAccess, "Doctor does not have access");

    // Remove doctor id 0 access to patient id 0
    let removingDoctorAccess =
      await medicalChainPatientInstance.removeDoctorAccess(0, accounts[4], {
        from: accounts[2],
      });

    // RemovingDoctorAccess event emitted for successful removing access of doctor
    truffleAssert.eventEmitted(removingDoctorAccess, "RemovingDoctorAccess");

    // Retrieve bool condition whether doctor id 0 is approved in patient id 0's approved doctors
    let doctorRemoved = await patientInstance.isDoctorApproved(0, accounts[4], {
      from: accounts[2],
    });

    // Test: Test if doctor id 0 has lost access to patient id 0
    // Outcome: Correct, no more access
    await assert.ok(!doctorRemoved, "Doctor still has access");
  });

  it("Test if adding and removing nurse's access works", async () => {
    // Creating a Nurse using accounts[5] address
    let newNurse = await nurseInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[5],
      }
    );

    // Test: Test if non patient can call this function for patient id 0
    // Outcome: Correct, unable to call
    await truffleAssert.reverts(
      medicalChainPatientInstance.giveNurseAccess(0, accounts[5], {
        from: accounts[4],
      }),
      "This person is not a patient!"
    );

    // Test: Test if other patient can call this function for patient id 0
    // Outcome: Correct, unable to call
    await truffleAssert.reverts(
      medicalChainPatientInstance.giveNurseAccess(0, accounts[5], {
        from: accounts[7],
      }),
      "This patient is not allowed to call on behalf of other patient"
    );

    // Grant nurse id 0 access to patient id 0
    let givingNurseAccess = await medicalChainPatientInstance.giveNurseAccess(
      0,
      accounts[5],
      {
        from: accounts[2],
      }
    );

    // GivingNurseAccess event emitted for successful giving access to nurse
    truffleAssert.eventEmitted(givingNurseAccess, "GivingNurseAccess");

    // Retrieve bool condition whether nurse id 0 is approved in patient id 0's approved nurses
    let NurseAccess = await patientInstance.isNurseApproved(0, accounts[5], {
      from: accounts[2],
    });

    // Test: Test if nurse id 0 has access to patient id 0
    // Outcome: Correct, able to access
    await assert.ok(NurseAccess, "Nurse does not have access");

    // Remove nurse id 0 access to patient id 0
    let removingNurseAccess =
      await medicalChainPatientInstance.removeNurseAccess(0, accounts[5], {
        from: accounts[2],
      });

    // RemovingNurseAccess event emitted for successful removing access of nurse
    truffleAssert.eventEmitted(removingNurseAccess, "RemovingNurseAccess");

    // Retrieve bool condition whether nurse id 0 is approved in patient id 0's approved nurses
    let NurseRemoved = await patientInstance.isNurseApproved(0, accounts[5], {
      from: accounts[2],
    });

    // Test: Test if nurse id 0 has access to patient id 0
    // Outcome: Correct, no more access
    await assert.ok(!NurseRemoved, "Nurse still has access");
  });

  it("Test retrieval of patients who gave approval for research", async () => {
    // Creating a Researcher using accounts[6] address
    let newResearcher = await researcherInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[6],
      }
    );

    // Test: Test if non patient can call this function for patient id 0
    // Outcome: Correct, unable to call
    await truffleAssert.reverts(
      medicalChainPatientInstance.giveResearcherAccess(0, {
        from: accounts[6],
      }),
      "This person is not a patient!"
    );

    // Test: Test if other patient can call this function for patient id 0
    // Outcome: Correct, unable to call
    await truffleAssert.reverts(
      medicalChainPatientInstance.giveResearcherAccess(0, {
        from: accounts[7],
      }),
      "This patient is not allowed to call on behalf of other patient"
    );

    // Patient id 0 grant researcher id 0 access
    let givingResearcherAccess =
      await medicalChainPatientInstance.giveResearcherAccess(0, {
        from: accounts[2],
      });

    // GivingResearcherAccess event emitted for successful giving access to researcher
    truffleAssert.eventEmitted(
      givingResearcherAccess,
      "GivingResearcherAccess"
    );

    // Retrieve bool condition whether patient id 0 is approved for research
    let researcherAccess = await patientInstance.getApprovedReseacher(0, {
      from: accounts[2],
    });

    // Test: Test if researcher id 0 has access to patient id 0 for research
    // Outcome: Correct
    await assert.ok(researcherAccess, "Researcher does not have access");

    // Retrieve list of approved patients for research by researcher id 0
    let viewApprovedPatients =
      await medicalChainStaffInstance.viewApprovedPatients({
        from: accounts[6],
      });

    // Test: Test if retrieved approved patients list's first patient is patient id 0
    // Outcome: Correct, unable to call
    await assert.strictEqual(
      viewApprovedPatients[0].words[0],
      0,
      "Patient record not accessed"
    );
  });
});

// /************************************ Testing for viewing of records (different conditions) ************************************/
// /************************************ Testing for viewing of records (different conditions) ************************************/
// /************************************ Testing for viewing of records (different conditions) ************************************/
// /************************************ Testing for viewing of records (different conditions) ************************************/
// /************************************ Testing for viewing of records (different conditions) ************************************/
contract(
  "Testing for viewing of records (different conditions)",
  function (accounts) {
    before(async () => {
      doctorInstance = await Doctor.deployed();
      ehrInstance = await EHR.deployed();
      medicalChainPatientInstance = await MedicalChainPatient.deployed();
      medicalChainStaffInstance = await MedicalChainStaff.deployed();
      nurseInstance = await Nurse.deployed();
      patientInstance = await Patient.deployed();
      researcherInstance = await Researcher.deployed();
    });

    console.log("Testing for viewing of records (different conditions)");

    /********* FUNCTIONALITY TESTS *********/
    it("Test practitioner viewing of specific record", async () => {
      // Creating a Patient using accounts[2] address
      let newPatient = await patientInstance.create(
        "Shawn",
        "Tan",
        "shawntan@gmail.com",
        "18/04/2000",
        true,
        "0x0000000000000000000000000000000000000000",
        {
          from: accounts[2],
        }
      );

      // Creating a Doctor (id: 0) using accounts[4] address
      let newDoctor = await doctorInstance.create(
        "Gary",
        "Tay",
        "garytay@gmail.com",
        "20/01/1980",
        {
          from: accounts[4],
        }
      );

      // Grant doctor id 0 access to patient id 0
      let givingDoctorAccess =
        await medicalChainPatientInstance.giveDoctorAccess(0, accounts[4], {
          from: accounts[2],
        });

      // Doctor id 0 registering patient id 0 with him
      let registeringPatient =
        await medicalChainStaffInstance.registerPatientWithDoctor(0, 0, {
          from: accounts[4],
        });

      // Doctor id 0 issue EHR record (id: 0) to patient id 0
      let addingEHR = await medicalChainStaffInstance.addNewEHR(
        EHR.RecordType.IMMUNISATION,
        0,
        "Immunisation Records",
        {
          from: accounts[4],
        }
      );

      // Doctor id 0 issue EHR record (id: 1) to patient id 0
      let addingEHR2 = await medicalChainStaffInstance.addNewEHR(
        EHR.RecordType.ALLERGIES,
        0,
        "Allergies Records",
        {
          from: accounts[4],
        }
      );

      // Creating a Doctor (id: 1) using accounts[8] address
      let secondNewDoctor = await doctorInstance.create(
        "Johnson",
        "Lee",
        "johnlee@gmail.com",
        "20/01/1989",
        {
          from: accounts[8],
        }
      );

      // Test: Test if non-practitioner can call this function
      // Outcome: Correct, Unable to call
      await truffleAssert.reverts(
        medicalChainStaffInstance.practitionerViewRecordByRecordID(0, 0, {
          from: accounts[2],
        }),
        "User is not a practitioner"
      );

      // Test: Test if doctor id 1 that is not in patient id 0's approved doctors can access his/her record
      // Outcome: Correct, doctor unable to view
      await truffleAssert.reverts(
        medicalChainStaffInstance.practitionerViewRecordByRecordID(0, 0, {
          from: accounts[8],
        }),
        "Doctor is not in patient's list of approved doctors"
      );

      // Grant doctor id 1 access to patient id 0
      let givingDoctorAccess2 =
        await medicalChainPatientInstance.giveDoctorAccess(0, accounts[8], {
          from: accounts[2],
        });

      // Test: Test if patient id 0 that is not in doctor id 1's list of patients will pass
      // Outcome: Correct, unable to proceed
      await truffleAssert.reverts(
        medicalChainStaffInstance.practitionerViewRecordByRecordID(0, 0, {
          from: accounts[8],
        }),
        "Patient is not in doctor's list of patients"
      );

      // Remove doctor id 1 access to patient id 0 for subsequent tests
      let removeDoctorAccess2 =
        await medicalChainPatientInstance.removeDoctorAccess(0, accounts[8], {
          from: accounts[2],
        });

      // Doctor id 0 retrieve EHR record id 0 from patient id 0
      let record =
        await medicalChainStaffInstance.practitionerViewRecordByRecordID(0, 0, {
          from: accounts[4],
        });

      // for viewing of the record and the details
      // console.log(record);

      // Test: Test if the retrieved record is EHR record id 0
      // Outcome: Correct
      await assert.strictEqual(
        record["0"]["words"][0],
        0,
        "Record given is not the requested one"
      );
    });

    it("Test researcher viewing of specific patient", async () => {
      // Creating a Researcher using accounts[6] address
      let newResearcher = await researcherInstance.create(
        "Maria",
        "Lee",
        "marialee@gmail.com",
        "25/06/1999",
        {
          from: accounts[6],
        }
      );

      // Patient id 0 grant researcher id 0 access
      let givingResearcherAccess =
        await medicalChainPatientInstance.giveResearcherAccess(0, {
          from: accounts[2],
        });

      // Test: Test if non researcher can call this function
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainStaffInstance.viewPatientByPatientId(0, {
          from: accounts[4],
        }),
        "This person is not a researcher!"
      );

      // Creating a Patient using accounts[7] address
      let newPatient2 = await patientInstance.create(
        "Shawn",
        "Tan",
        "shawntan@gmail.com",
        "18/04/2000",
        false,
        "0x0000000000000000000000000000000000000000",
        {
          from: accounts[7],
        }
      );

      // Test: Test if researcher id 0 can view patient id 1's data (not given approval for research)
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainStaffInstance.viewPatientByPatientId(1, {
          from: accounts[6],
        }),
        "Patient has not approved data for research purposes"
      );

      // Reearcher id 0 retrieve patient id 0's data
      let patientData = await medicalChainStaffInstance.viewPatientByPatientId(
        0,
        {
          from: accounts[6],
        }
      );

      // for viewing of the patient data
      // console.log(patientData);

      // Test: Test if retrieved patient data's patient id matches patient id 0
      // Outcome: Correct
      await assert.strictEqual(
        patientData["0"]["words"][0],
        0,
        "Patient data given is not the requested one"
      );
    });

    it("Test patient viewing of all acknowledged records", async () => {
      // Patient id 0 acknowledges record id 0 issued by doctor id 0
      let signingOff =
        await medicalChainPatientInstance.patientAcknowledgeRecord(0, {
          from: accounts[2],
        });

      // Patient id 0 retrieves his/her own list of acknowledged record ids
      let listOfAcknowledgedRecordIds =
        await medicalChainPatientInstance.patientViewAllAcknowledgedRecords(0, {
          from: accounts[2],
        });

      // for viewing of the acknowledged record id array belonging to patient
      // console.log(listOfAcknowledgedRecordIds);

      // Test: Test that patient id 0's retrieved acknowledged record ids contains 1 record
      // Outcome: Correct
      assert.strictEqual(
        listOfAcknowledgedRecordIds.length,
        1,
        "Acknowledged records quantity does not match!"
      );

      // Test: Test that patient id 0's retrieved acknowledged record id first EHR record id is 0
      // Outcome: Correct
      assert.strictEqual(
        listOfAcknowledgedRecordIds[0]["words"][0],
        0,
        "Acknowledged record does not exist in patient's acknowledged records"
      );
    });

    it("Test patient viewing of all records", async () => {
      // Patient id 0 retrieves his/her own list of record ids
      let listOfRecordIds =
        await medicalChainPatientInstance.patientViewAllRecords(0, {
          from: accounts[2],
        });

      // for viewing of the record id array belonging to patient
      // console.log(listOfRecordIds);

      // Test: Test that patient id 0's retrieved record ids contains 2 records
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordIds.length,
        2,
        "Records quantity does not match!"
      );

      // Test: Test that patient id 0's retrieved record ids first record's id is 0
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordIds[0]["words"][0],
        0,
        "Record does not exist in patient's records"
      );

      // Test: Test that patient id 0's retrieved record ids second record's id is 1
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordIds[1]["words"][0],
        1,
        "Record does not exist in patient's records"
      );
    });

    it("Test patient viewing of filtered records by record type", async () => {
      // Doctor id 0 issues an EHR RecordType IMMUNISATION (id: 2) to patient id 0
      let addingEHR3 = await medicalChainStaffInstance.addNewEHR(
        EHR.RecordType.IMMUNISATION,
        0,
        "Immunisation Records",
        {
          from: accounts[4],
        }
      );

      // Test: Test if non patient can call this function for patient id 0
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainPatientInstance.patientViewRecordsByRecordType(
          0,
          EHR.RecordType.IMMUNISATION,
          { from: accounts[4] }
        ),
        "This person is not a patient!"
      );

      // Test: Test if other patient can call this function for patient id 0
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainPatientInstance.patientViewRecordsByRecordType(
          0,
          EHR.RecordType.IMMUNISATION,
          { from: accounts[7] }
        ),
        "This patient is not allowed to call on behalf of other patient"
      );

      // Retrieve list of filtered record ids according to stated RecordType IMMUNISATION for patient id 0
      let listOfFilterRecordIds =
        await medicalChainPatientInstance.patientViewRecordsByRecordType(
          0,
          EHR.RecordType.IMMUNISATION,
          { from: accounts[2] }
        );

      // Test: Test that patient id 0's retrieved filtered record ids contains 2 records
      // Outcome: Correct
      assert.strictEqual(
        listOfFilterRecordIds.length,
        2,
        "Records quantity does not match!"
      );

      // Test: Test that patient id 0's retrieved filtered record ids first record's id is 0
      // Outcome: Correct
      assert.strictEqual(
        listOfFilterRecordIds[0]["words"][0],
        0,
        "Record does not exist in patient's records"
      );

      // Test: Test that patient id 0's retrieved filtered record ids second record's id is 2
      // Outcome: Correct
      assert.strictEqual(
        listOfFilterRecordIds[1]["words"][0],
        2,
        "Record does not exist in patient's records"
      );
    });

    it("Test practitioner viewing of filtered records by record type", async () => {
      // Test: Test if non practitioner can call this function
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainStaffInstance.practitionerViewRecordsByRecordType(
          0,
          EHR.RecordType.IMMUNISATION,
          { from: accounts[2] }
        ),
        "User is not a practitioner"
      );

      // Test: Test if practitioner can view record of patient id 0 if not in patient's approved list
      // Outcome: Correct, unable to proceed
      await truffleAssert.reverts(
        medicalChainStaffInstance.practitionerViewRecordsByRecordType(
          0,
          EHR.RecordType.IMMUNISATION,
          { from: accounts[8] }
        ),
        "Doctor is not in patient's list of approved doctors"
      );

      // Retrieve list of filtered record ids according to stated RecordType IMMUNISATION for patient id 0
      let listOfFilterRecordIds =
        await medicalChainStaffInstance.practitionerViewRecordsByRecordType(
          0,
          EHR.RecordType.IMMUNISATION,
          { from: accounts[4] }
        );

      // Test: Test that patient id 0's retrieved filtered record ids contains 2 records
      // Outcome: Correct
      assert.strictEqual(
        listOfFilterRecordIds.length,
        2,
        "Records quantity does not match!"
      );

      // Test: Test that patient id 0's retrieved filtered record ids first record's id is 0
      // Outcome: Correct
      assert.strictEqual(
        listOfFilterRecordIds[0]["words"][0],
        0,
        "Record does not exist in patient's records"
      );

      // Test: Test that patient id 0's retrieved filtered record ids second record's id is 2
      // Outcome: Correct
      assert.strictEqual(
        listOfFilterRecordIds[1]["words"][0],
        2,
        "Record does not exist in patient's records"
      );
    });

    it("Test patient viewing of all records by doctor", async () => {
      // Test: Test if other patient can call this function for patient id 0
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainPatientInstance.patientViewRecordsByDoctor(0, 0, {
          from: accounts[7],
        }),
        "This patient is not allowed to call on behalf of other patient"
      );

      // Test: Test if non patient can call this function for patient id 0
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainPatientInstance.patientViewRecordsByDoctor(0, 0, {
          from: accounts[4],
        }),
        "This person is not a patient!"
      );

      // Retrieve list of record ids issued by doctor id 0 for patient id 0
      let listOfRecordByDoctor =
        await medicalChainPatientInstance.patientViewRecordsByDoctor(0, 0, {
          from: accounts[2],
        });

      // Test: Test that patient id 0's retrieved record ids according to doctor id contains 3 records
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordByDoctor.length,
        3,
        "Records quantity does not match!"
      );

      // Test: Test that patient id 0's retrieved record ids according to doctor id first record's id is 0
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordByDoctor[0]["words"][0],
        0,
        "Record was not issued by given doctor"
      );

      // Test: Test that patient id 0's retrieved record ids according to doctor id second record's id is 1
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordByDoctor[1]["words"][0],
        1,
        "Record was not issued by given doctor"
      );
    });

    it("Test practitioner viewing of all patient records", async () => {
      // Test: Test if non practitioner can call this function
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainStaffInstance.practitionerViewAllRecords(0, {
          from: accounts[2],
        }),
        "User is not a practitioner"
      );

      // Test: Test if practitioner can view record of patient id 0 if not in patient's approved list
      // Outcome: Correct, unable to proceed
      await truffleAssert.reverts(
        medicalChainStaffInstance.practitionerViewAllRecords(0, {
          from: accounts[8],
        }),
        "Doctor is not in patient's list of approved doctors"
      );

      // Retrieve list of record ids for patient id 0
      let listOfRecordIds =
        await medicalChainStaffInstance.practitionerViewAllRecords(0, {
          from: accounts[4],
        });

      // for viewing of the record id array belonging to patient
      // console.log(listOfRecordIds);

      // Test: Test that patient id 0's retrieved record ids by doctor id 0 contains 3 records
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordIds.length,
        3,
        "Records quantity does not match!"
      );

      // Test: Test that patient id 0's retrieved record ids by doctor id 0 first record's id is 0
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordIds[0]["words"][0],
        0,
        "Record does not exist in patient's records"
      );

      // Test: Test that patient id 0's retrieved record ids by doctor id 0 second record's id is 1
      // Outcome: Correct
      assert.strictEqual(
        listOfRecordIds[1]["words"][0],
        1,
        "Record does not exist in patient's records"
      );
    });
  }
);
