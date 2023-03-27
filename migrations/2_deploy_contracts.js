const Doctor = artifacts.require("Doctor");
const EHR = artifacts.require("EHR");
const medicalChain = artifacts.require("medicalChain");
const Nurse = artifacts.require("Nurse");
const Patient = artifacts.require("Patient");

module.exports = (deployer, network, accounts) => {
  deployer.then(async () => {
    await deployer.deploy(Doctor);
    await deployer.deploy(medicalChain);
    await deployer.deploy(EHR);
    await deployer.deploy(Nurse);
    await deployer.deploy(Patient);
    await deployer.deploy(
      Patient.address,
      Doctor.address,
      Nurse.address,
      Patient.address,
      EHR.address
    );
  });
};
