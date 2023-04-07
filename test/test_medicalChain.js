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

contract("MedicalChain", function (accounts) {
  before(async () => {
    doctorInstance = await Doctor.deployed();
    ehrInstance = await EHR.deployed();
    medicalChainInstance = await MedicalChain.deployed();
    nurseInstance = await Nurse.deployed();
    patientInstance = await Patient.deployed();
    researcherInstance = await Researcher.deployed();
  });

  console.log("Testing Medical Chain Contract");

  /********* BASIC CREATION TESTS *********/

  it("Test if medical chain exists", async () => {
    let testingTest = await medicalChainInstance.testingTest(10, {
      from: accounts[1],
    });
    truffleAssert.eventEmitted(testingTest, "testEvent");
  });

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

    let newNurse = await nurseInstance.create(
      "Maria",
      "Lee",
      "marialee@gmail.com",
      "25/06/1999",
      {
        from: accounts[5],
      }
    );

    // Grant doctor access
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

  it("Test if able to get patient id from address", async () => {
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

    let patientId = await patientInstance.getPatientIdFromPatientAddress(
      accounts[2],
      {
        from: accounts[2],
      }
    );
    // console.log(patientId["logs"][0]["args"]["0"].toString());

    await assert.strictEqual(
      patientId["logs"][0]["args"]["0"].toString(),
      "0",
      "Patient ID does not match!"
    );
  });

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
    // // Patient sign off on record
    // let patientSigningRecord =
    //   await medicalChainInstance.patientAcknowledgeRecord(0, {
    //     from: accounts[2],
    //   });
    // truffleAssert.eventEmitted(patientSigningRecord, "AcknowledgingRecord");
  });

  it("Test viewing of specific record", async () => {});

  it("Test viewing of specific patient", async () => {});

  it("Test viewing of all records acknowledged by patient", async () => {});

  it("Test viewing of all records under patient", async () => {});

  it("Test viewing of filtered records by record type", async () => {});

  it("Test viewing of all records by practitioner", async () => {});

  it("Test record update", async () => {});

  // Fix getting research patients. Doesn't seem to fetch any.
  it("Test retrieval of patients who gave approval for research", async () => {
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
