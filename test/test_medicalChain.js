const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

var Doctor = artifacts.require("../contracts/Doctor.sol");
var EHR = artifacts.require("../contracts/EHR.sol");
var MedicalChain = artifacts.require("../contracts/medicalChain.sol");
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
    medicalChainInstance = await MedicalChain.deployed();
    nurseInstance = await Nurse.deployed();
    patientInstance = await Patient.deployed();
    researcherInstance = await Researcher.deployed();
  });

  console.log("Testing Begins: Testing for creation");

  /********* BASIC CREATION TESTS *********/

  it("Test if medical chain exists", async () => {
    let testingTest = await medicalChainInstance.testingTest(10, {
      from: accounts[1],
    });
    truffleAssert.eventEmitted(testingTest, "testEvent");
  });

  // Do we need to check if we can nominate secondary user if they are not a registered patient yet
  it("Test if patient created and email can be fetched", async () => {
    let newPatient = await patientInstance.create(
      "Shawn",
      "Tan",
      "shawntan@gmail.com",
      "18/04/2000",
      true,
      accounts[3],
      {
        from: accounts[2],
      }
    );

    truffleAssert.eventEmitted(newPatient, "PatientAdded");

    await assert.notStrictEqual(
      newPatient,
      undefined,
      "Failed to create patient"
    );

    let email = await patientInstance.getEmailAddress(0, {
      from: accounts[2],
    });

    await assert.strictEqual(
      email,
      "shawntan@gmail.com",
      "email does not match!"
    );
  });

  it("Test if doctor created", async () => {
    let newDoctor = await doctorInstance.create(
      "Gary",
      "Tay",
      "garytay@gmail.com",
      "20/01/1980",
      {
        from: accounts[4],
      }
    );

    truffleAssert.eventEmitted(newDoctor, "DoctorAdded");

    await assert.notStrictEqual(
      newDoctor,
      undefined,
      "Failed to create doctor"
    );
  });

  it("Test if EHR created", async () => {
    let newEHR = await ehrInstance.add(
      EHR.RecordType.IMMUNISATION,
      "Immunisation Records",
      accounts[2],
      accounts[4],
      {
        from: accounts[4],
      }
    );

    truffleAssert.eventEmitted(newEHR, "EHRAdded");

    await assert.notStrictEqual(newEHR, undefined, "Failed to create EHR");
  });

  it("Test query of RecordType matches", async () => {
    let recordMatchResult = await ehrInstance.doesRecordMatchRecordType(
      0,
      EHR.RecordType.IMMUNISATION
    );

    await assert.strictEqual(
      recordMatchResult,
      true,
      "EHR type does not match!"
    );
  });

  it("Test if nurse created", async () => {
    let newNurse = await nurseInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[5],
      }
    );

    truffleAssert.eventEmitted(newNurse, "NurseAdded");

    await assert.notStrictEqual(newNurse, undefined, "Failed to create nurse");
  });

  it("Test if researcher created", async () => {
    let newResearcher = await researcherInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[6],
      }
    );

    truffleAssert.eventEmitted(newResearcher, "ResearcherAdded");

    await assert.notStrictEqual(
      newResearcher,
      undefined,
      "Failed to create researcher"
    );
  });

  it("Test if able to get patient id from address", async () => {
    let patientId = await patientInstance.getPatientIdFromPatientAddress(
      accounts[2],
      {
        from: accounts[2],
      }
    );

    await assert.strictEqual(
      patientId["words"][0],
      0,
      "Patient ID does not match!"
    );

    let newPatient = await patientInstance.create(
      "Gavin",
      "Koh",
      "gavinkoh@gmail.com",
      "28/09/2000",
      true,
      accounts[3],
      {
        from: accounts[7],
      }
    );

    let secondPatientId = await patientInstance.getPatientIdFromPatientAddress(
      accounts[7],
      {
        from: accounts[7],
      }
    );

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
    medicalChainInstance = await MedicalChain.deployed();
    nurseInstance = await Nurse.deployed();
    patientInstance = await Patient.deployed();
    researcherInstance = await Researcher.deployed();
  });

  console.log("Testing begins: Testing for practioner's access");

  /********* FUNCTIONALITY TESTS *********/
  it("Test EHR adding", async () => {
    let newPatient = await patientInstance.create(
      "Shawn",
      "Tan",
      "shawntan@gmail.com",
      "18/04/2000",
      true,
      accounts[3],
      {
        from: accounts[2],
      }
    );

    let newDoctor = await doctorInstance.create(
      "Gary",
      "Tay",
      "garytay@gmail.com",
      "20/01/1980",
      {
        from: accounts[4],
      }
    );

    // Grant doctor access
    let givingDoctorAccess = await medicalChainInstance.giveDoctorAccess(
      0,
      accounts[4],
      {
        from: accounts[2],
      }
    );

    // Register patient with doctor
    let registeringPatient =
      await medicalChainInstance.registerPatientWithDoctor(0, 0, {
        from: accounts[4],
      });

    // Ensure initial record count is 0
    let recordsCount0 = await patientInstance.getRecordsCount(0, {
      from: accounts[2],
    });

    await assert.strictEqual(
      recordsCount0.words[0],
      0,
      "Initial  count does not match"
    );

    // Add EHR
    let addingEHR = await medicalChainInstance.addNewEHR(
      EHR.RecordType.IMMUNISATION,
      0,
      "Immunisation Records",
      {
        from: accounts[4],
      }
    );

    truffleAssert.eventEmitted(addingEHR, "AddingEHR");

    // Check that record count increased by 1
    let recordsCount1 = await patientInstance.getRecordsCount(0, {
      from: accounts[2],
    });

    // console.log(recordsCount);
    // console.log(recordsCount.words[0]);
    // console.log(recordsCount[words][0]);

    await assert.strictEqual(
      recordsCount1.words[0],
      1,
      "Record count does not match"
    );
    // // Patient sign off on record
    // let patientSigningRecord =
    //   await medicalChainInstance.patientAcknowledgeRecord(0, {
    //     from: accounts[2],
    //   });

    // truffleAssert.eventEmitted(patientSigningRecord, "AcknowledgingRecord");
  });

  // Seems to be keeping previous state?
  // Need to add in remove function
  it("Test EHR removing", async () => {});

  // Need to fix EHR acknowledging function
  it("Test EHR acknowledging", async () => {
    let newPatient = await patientInstance.create(
      "Chad",
      "Teo",
      "chadteo@gmail.com",
      "20/02/2000",
      true,
      accounts[2],
      {
        from: accounts[3],
      }
    );

    // Test: testing if patient can acknowledge other patient's record
    // Outcome: Correct, patient unable to knowledge
    truffleAssert.reverts(
      medicalChainInstance.patientAcknowledgeRecord(0, {
        from: accounts[3],
      }),
      "Record does not belong to this patient"
    );

    // Patient acknowledge on own record
    let patientSigningRecord =
      await medicalChainInstance.patientAcknowledgeRecord(0, {
        from: accounts[2],
      });
    truffleAssert.eventEmitted(patientSigningRecord, "AcknowledgingRecord");
  });
});

/************************************ Testing for practioner's access ************************************/
/************************************ Testing for practioner's access ************************************/
/************************************ Testing for practioner's access ************************************/
/************************************ Testing for practioner's access ************************************/
/************************************ Testing for practioner's access ************************************/

contract("Testing for practioner's access", function (accounts) {
  before(async () => {
    doctorInstance = await Doctor.deployed();
    ehrInstance = await EHR.deployed();
    medicalChainInstance = await MedicalChain.deployed();
    nurseInstance = await Nurse.deployed();
    patientInstance = await Patient.deployed();
    researcherInstance = await Researcher.deployed();
  });

  console.log("Testing begins: Testing for practioner's access");

  /********* FUNCTIONALITY TESTS *********/

  it("Test if adding and removing doctor's access works", async () => {
    let newPatient = await patientInstance.create(
      "Shawn",
      "Tan",
      "shawntan@gmail.com",
      "18/04/2000",
      true,
      accounts[3],
      {
        from: accounts[2],
      }
    );

    let newDoctor = await doctorInstance.create(
      "Gary",
      "Tay",
      "garytay@gmail.com",
      "20/01/1980",
      {
        from: accounts[4],
      }
    );

    // Grant doctor access
    let givingDoctorAccess = await medicalChainInstance.giveDoctorAccess(
      0,
      accounts[4],
      {
        from: accounts[2],
      }
    );

    //  Checks to see if doctor successfully granted access
    truffleAssert.eventEmitted(givingDoctorAccess, "GivingDoctorAccess");

    let doctorAccess = await patientInstance.isDoctorApproved(0, accounts[4], {
      from: accounts[2],
    });

    await assert.ok(doctorAccess, "Doctor does not have access");

    // Remove doctor access
    let removingDoctorAccess = await medicalChainInstance.removeDoctorAccess(
      0,
      accounts[4],
      {
        from: accounts[2],
      }
    );

    //  Checks to see if doctor successfully removed access
    truffleAssert.eventEmitted(removingDoctorAccess, "RemovingDoctorAccess");

    let doctorRemoved = await patientInstance.isDoctorApproved(0, accounts[4], {
      from: accounts[2],
    });

    await assert.ok(!doctorRemoved, "Doctor still has access");
  });

  it("Test if adding and removing nurse's access works", async () => {
    let newNurse = await nurseInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[5],
      }
    );

    // Grant nurse access
    let givingNurseAccess = await medicalChainInstance.giveNurseAccess(
      0,
      accounts[5],
      {
        from: accounts[2],
      }
    );

    //  Checks to see if Nurse successfully granted access
    truffleAssert.eventEmitted(givingNurseAccess, "GivingNurseAccess");

    let NurseAccess = await patientInstance.isNurseApproved(0, accounts[5], {
      from: accounts[2],
    });

    await assert.ok(NurseAccess, "Nurse does not have access");

    // Remove Nurse access
    let removingNurseAccess = await medicalChainInstance.removeNurseAccess(
      0,
      accounts[5],
      {
        from: accounts[2],
      }
    );

    //  Checks to see if Nurse successfully removed access
    truffleAssert.eventEmitted(removingNurseAccess, "RemovingNurseAccess");

    let NurseRemoved = await patientInstance.isNurseApproved(0, accounts[5], {
      from: accounts[2],
    });

    await assert.ok(!NurseRemoved, "Nurse still has access");
  });

  // Fix getting research patients. Doesn't seem to fetch any.
  it("Test retrieval of patients who gave approval for research", async () => {
    let newResearcher = await researcherInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[6],
      }
    );

    // Grant researcher access
    let givingResearcherAccess =
      await medicalChainInstance.giveResearcherAccess(0, {
        from: accounts[2],
      });

    //  Checks to see if Researcher successfully granted access
    truffleAssert.eventEmitted(
      givingResearcherAccess,
      "GivingResearcherAccess"
    );

    let researcherAccess = await patientInstance.getApprovedReseacher(0, {
      from: accounts[2],
    });

    await assert.ok(researcherAccess, "Researcher does not have access");

    // Get list of approved patients
    let viewApprovedPatients = await medicalChainInstance.viewApprovedPatients({
      from: accounts[6],
    });

    //  Checks to see if Researcher getting patients
    truffleAssert.eventEmitted(viewApprovedPatients, "GettingApprovedPatients");

    console.log(viewApprovedPatients["logs"][0]["args"]);
  });
});

/************************************ Testing for viewing of records (different conditions) ************************************/
/************************************ Testing for viewing of records (different conditions) ************************************/
/************************************ Testing for viewing of records (different conditions) ************************************/
/************************************ Testing for viewing of records (different conditions) ************************************/
/************************************ Testing for viewing of records (different conditions) ************************************/

contract(
  "Testing for viewing of records (different conditions)",
  function (accounts) {
    before(async () => {
      doctorInstance = await Doctor.deployed();
      ehrInstance = await EHR.deployed();
      medicalChainInstance = await MedicalChain.deployed();
      nurseInstance = await Nurse.deployed();
      patientInstance = await Patient.deployed();
      researcherInstance = await Researcher.deployed();
    });

    console.log("Testing for viewing of records (different conditions)");

    /********* FUNCTIONALITY TESTS *********/
    // Need to test for nurse also
    it("Test practitioner viewing of specific record", async () => {
      let newPatient = await patientInstance.create(
        "Shawn",
        "Tan",
        "shawntan@gmail.com",
        "18/04/2000",
        true,
        accounts[3],
        {
          from: accounts[2],
        }
      );

      let newDoctor = await doctorInstance.create(
        "Gary",
        "Tay",
        "garytay@gmail.com",
        "20/01/1980",
        {
          from: accounts[4],
        }
      );

      // Grant doctor access
      let givingDoctorAccess = await medicalChainInstance.giveDoctorAccess(
        0,
        accounts[4],
        {
          from: accounts[2],
        }
      );

      // Register patient with doctor
      let registeringPatient =
        await medicalChainInstance.registerPatientWithDoctor(0, 0, {
          from: accounts[4],
        });

      // Add EHR
      let addingEHR = await medicalChainInstance.addNewEHR(
        EHR.RecordType.IMMUNISATION,
        0,
        "Immunisation Records",
        {
          from: accounts[4],
        }
      );

      // Add EHR
      let addingEHR2 = await medicalChainInstance.addNewEHR(
        EHR.RecordType.ALLERGIES,
        0,
        "Allergies Records",
        {
          from: accounts[4],
        }
      );

      truffleAssert.eventEmitted(addingEHR, "AddingEHR");
      truffleAssert.eventEmitted(addingEHR2, "AddingEHR");

      let secondNewDoctor = await doctorInstance.create(
        "Johnson",
        "Lee",
        "johnlee@gmail.com",
        "20/01/1989",
        {
          from: accounts[8],
        }
      );

      // Test: testing if non-practitioner can call this function
      // Outcome: Correct, Unable to call
      await truffleAssert.reverts(
        medicalChainInstance.practitionerViewRecordByRecordID(0, 0, {
          from: accounts[2],
        }),
        "User is not a practitioner"
      );

      // Test: testing if doctor that is not in patient's approvedDoctors will pass
      // Outcome: Correct, Doctor unable to view
      await truffleAssert.reverts(
        medicalChainInstance.practitionerViewRecordByRecordID(0, 0, {
          from: accounts[8],
        }),
        "Doctor is not in patient's list of approved doctors"
      );

      

      // Test: testing if invalid record id will throw an error
      // Outcome: Correct
      await truffleAssert.reverts(
        medicalChainInstance.practitionerViewRecordByRecordID(0, 2, {
          from: accounts[4],
        }),
        "Record ID given is not valid"
      );

      let record = await medicalChainInstance.practitionerViewRecordByRecordID(
        0,
        0,
        {
          from: accounts[4],
        }
      );

      // for viewing of the record and the details
      // console.log(record);

      // checking that the record data given belongs to record id 0
      await assert.strictEqual(
        record["0"]["words"][0],
        0,
        "Record given is not the requested one"
      );
    });

    it("Test researcher viewing of specific patient", async () => {
      let newResearcher = await researcherInstance.create(
        "Maria",
        "Lee",
        "marialee@gmail.com",
        "25/06/1999",
        {
          from: accounts[6],
        }
      );

      // Grant researcher access
      let givingResearcherAccess =
        await medicalChainInstance.giveResearcherAccess(0, {
          from: accounts[2],
        });

      // testing if Doctor can view patient's data
      await truffleAssert.reverts(
        medicalChainInstance.viewPatientByPatientID(0, { from: accounts[4] }),
        "This person is not a researcher!"
      );

      let newPatient = await patientInstance.create(
        "Shawn",
        "Tan",
        "shawntan@gmail.com",
        "18/04/2000",
        false,
        accounts[3],
        {
          from: accounts[7],
        }
      );

      // testing if researcher can view patient that has not given access
      await truffleAssert.reverts(
        medicalChainInstance.viewPatientByPatientID(1, { from: accounts[6] }),
        "Patient has not approved data for research purposes"
      );

      let patientData = await medicalChainInstance.viewPatientByPatientID(0, {
        from: accounts[6],
      });

      // for viewing of the patient data
      // console.log(patientData);

      // checking that the patient data given belongs to patient id 0
      await assert.strictEqual(
        patientData["0"]["words"][0],
        0,
        "Patient data given is not the requested one"
      );
    });

    it("Test patient viewing of all acknowledged records", async () => {
      let signingOff = await medicalChainInstance.patientAcknowledgeRecord(0, {
        from: accounts[2],
      });

      let listOfAcknowledgedRecordIds =
        await medicalChainInstance.patientViewAllAcknowledgedRecords(0, {
          from: accounts[2],
        });

      // for viewing of the acknowledged record id array belonging to patient
      // console.log(listOfAcknowledgedRecordIds);

      // checking the length of patient's acknowledged record is 1
      assert.strictEqual(
        listOfAcknowledgedRecordIds.length,
        1,
        "Acknowledged records quantity does not match!"
      );

      assert.strictEqual(
        listOfAcknowledgedRecordIds[0]["words"][0],
        0,
        "Acknowledged record does not exist in patient's acknowledged records"
      );
    });

    it("Test patient viewing of all records", async () => {
      let listOfRecordIds = await medicalChainInstance.patientViewAllRecords(
        0,
        {
          from: accounts[2],
        }
      );

      // for viewing of the record id array belonging to patient
      // console.log(listOfRecordIds);

      // checking the length of patient's record is 2
      assert.strictEqual(
        listOfRecordIds.length,
        2,
        "Records quantity does not match!"
      );

      assert.strictEqual(
        listOfRecordIds[0]["words"][0],
        0,
        "Record does not exist in patient's records"
      );

      assert.strictEqual(
        listOfRecordIds[1]["words"][0],
        1,
        "Record does not exist in patient's records"
      );
    });

    it("Test patient viewing of filtered records by record type", async () => {
      // console.log(await medicalChainInstance)
    });

    it("Test practitioner viewing of filtered records by record type", async () => {
    });

    it("Test patient viewing of all records by doctor", async () => {
      // Test: testing if another patient can view patient id 0's records by doctor
      // Outcome: Correct, unable to view
      await truffleAssert.reverts(
        medicalChainInstance.patientViewRecordsByDoctor(0, 0, {
          from: accounts[7],
        }),
        "Current user is not the intended patient!"
      );

      // Test: testing if non-patient can view patient id 0's records by doctor
      // Outcome: Correct, unable to view
      await truffleAssert.reverts(
        medicalChainInstance.patientViewRecordsByDoctor(0, 0, {
          from: accounts[4],
        }),
        "This person is not a patient!"
      );

      let listOfRecordByDoctor =
        await medicalChainInstance.patientViewRecordsByDoctor(0, 0, {
          from: accounts[2],
        });

      // checking the length of patient's record is 2
      assert.strictEqual(
        listOfRecordByDoctor.length,
        2,
        "Records quantity does not match!"
      );

      assert.strictEqual(
        listOfRecordByDoctor[0]["words"][0],
        0,
        "Record was not issued by given doctor"
      );

      assert.strictEqual(
        listOfRecordByDoctor[1]["words"][0],
        1,
        "Record was not issued by given doctor"
      );
    });

    it("Test practitioner viewing of all patient records", async () => {
      // Test: testing if non practitioner can call this function
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainInstance.practitionerViewAllRecords(0, {
          from: accounts[2],
        }),
        "User is not a practitioner"
      );

      // Test: testing if non approved doctor can call this function
      // Outcome: Correct, unable to call
      await truffleAssert.reverts(
        medicalChainInstance.practitionerViewAllRecords(0, {
          from: accounts[8],
        }),
        "Doctor is not in patient's list of approved doctors"
      );

      let listOfRecordIds =
        await medicalChainInstance.practitionerViewAllRecords(0, {
          from: accounts[4],
        });

      // for viewing of the record id array belonging to patient
      //   console.log(listOfRecordIds);

      // checking the length of patient's record is 2
      assert.strictEqual(
        listOfRecordIds.length,
        2,
        "Records quantity does not match!"
      );

      assert.strictEqual(
        listOfRecordIds[0]["words"][0],
        0,
        "Record does not exist in patient's records"
      );

      assert.strictEqual(
        listOfRecordIds[1]["words"][0],
        1,
        "Record does not exist in patient's records"
      );
    });

    it("Test record update", async () => {
      let beforeUpdate =
        await medicalChainInstance.practitionerViewRecordByRecordID(0, 0, {
          from: accounts[4],
        });

      // console.log(beforeUpdate["fileName"]);

      // ensure that record's file name before update is Immunisation Records
      assert.strictEqual(
        beforeUpdate["fileName"] == "Immunisation Records",
        true,
        "Incorrect record chosen!"
      );

      await truffleAssert.reverts(
        medicalChainInstance.updateRecordByRecordId(
          0,
          0,
          EHR.RecordType.LABORATORY_RESULTS,
          "Laboratory Results",
          { from: accounts[2] }
        ),
        "User is not a doctor!"
      );

      await truffleAssert.reverts(
        medicalChainInstance.updateRecordByRecordId(
          0,
          0,
          EHR.RecordType.LABORATORY_RESULTS,
          "Laboratory Results",
          { from: accounts[8] }
        ),
        "Doctor is not issuer!"
      );

      let updateRecord = await medicalChainInstance.updateRecordByRecordId(
        0,
        0,
        EHR.RecordType.LABORATORY_RESULTS,
        "Laboratory Results",
        { from: accounts[4] }
      );
      let afterUpdate =
        await medicalChainInstance.practitionerViewRecordByRecordID(0, 0, {
          from: accounts[4],
        });

      assert.strictEqual(
        afterUpdate["fileName"] == "Laboratory Results",
        true,
        "Update failed!"
      );
    });
  }
);
