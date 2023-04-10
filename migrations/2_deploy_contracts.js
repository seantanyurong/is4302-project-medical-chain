const Doctor = artifacts.require("Doctor");
const EHR = artifacts.require("EHR");
const medicalChainPatient = artifacts.require("medicalChainPatient");
const medicalChainStaff = artifacts.require("medicalChainStaff");
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
      medicalChainPatient,
      Patient.address,
      Doctor.address,
      Nurse.address,
      EHR.address,
      Researcher.address
    );
    await deployer.deploy(
      medicalChainStaff,
      Patient.address,
      Doctor.address,
      Nurse.address,
      EHR.address,
      Researcher.address
    );
  });
};
