const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

var Doctor = artifacts.require("../contracts/Doctor.sol");
var EHR = artifacts.require("../contracts/EHR.sol");
var MedicalChain = artifacts.require("../contracts/medicalChain.sol");
var Nurse = artifacts.require("../contracts/Nurse.sol");
var Patient = artifacts.require("../contracts/Patient.sol");
var Researcher = artifacts.require("../contracts/Researcher.sol");

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

  it("Medical chain exists", async () => {
    let testingTest = await medicalChainInstance.testingTest(10, {
      from: accounts[1],
    });
    truffleAssert.eventEmitted(testingTest, "testEvent");
  });
});
