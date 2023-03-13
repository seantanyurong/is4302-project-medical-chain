const Dice = artifacts.require("Dice");
const DiceBattle = artifacts.require("DiceBattle");
const DiceMarket = artifacts.require("DiceMarket");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(Patient);
};
