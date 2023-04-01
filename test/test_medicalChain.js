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

    let email = await patientInstance.getEmailAddress(1, {
      from: accounts[2],
    });

    console.log("chicken");
    console.log(email);
  });

  it("Test if doctor created", async () => {});

  it("Test if EHR created", async () => {});

  it("Test if nurse created", async () => {});

  it("Test if researcher created", async () => {});

  it("Test if adding and removing doctor's access works", async () => {});

  it("Test if adding and removing nurse's access works", async () => {});

  it("Test if able to get patient id from address", async () => {});

  it("Test EHR adding and patient sign off process", async () => {});

  it("Test retrieval of patients who gave approval for research", async () => {});
});
