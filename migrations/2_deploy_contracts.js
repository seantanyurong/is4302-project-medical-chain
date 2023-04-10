const Doctor = artifacts.require("Doctor");
const EHR = artifacts.require("EHR");
const medicalChain = artifacts.require("medicalChain");
const Nurse = artifacts.require("Nurse");
const Patient = artifacts.require("Patient");
const Researcher = artifacts.require("Researcher");

module.exports = (deployer, network, accounts) => {
  deployer.then(async () => {
    await deployer.deploy(EHR);
    await deployer.deploy(Doctor, EHR.address);
    await deployer.deploy(Nurse, EHR.address);
    await deployer.deploy(Patient, EHR.address);
    await deployer.deploy(Researcher);
    await deployer.deploy(
      medicalChain,
      Patient.address,
      Doctor.address,
      Nurse.address,
      EHR.address,
      Researcher.address
    );
  });
};
