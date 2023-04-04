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

  it("Test if researcher created", async () => {});

  /********* FUNCTIONALITY TESTS *********/

  it("Test if adding and removing doctor's access works", async () => {});

  it("Test if adding and removing nurse's access works", async () => {});

  it("Test if able to get patient id from address", async () => {});

  it("Test EHR adding", async () => {});

  it("Test EHR removing", async () => {});

  it("Test EHR acknowledging", async () => {});

  it("Test viewing of specific record", async () => {});

  it("Test viewing of specific patient", async () => {});

  it("Test viewing of all records acknowledged by patient", async () => {});

  it("Test viewing of all records under patient", async () => {});

  it("Test viewing of filtered records by record type", async () => {});

  it("Test number of record types", async () => {});

  it("Test viewing of all records by practitioner", async () => {});

  it("Test record update", async () => {});

  it("Test retrieval of patients who gave approval for research", async () => {});
});
