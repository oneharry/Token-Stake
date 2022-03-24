const StakeContract = artifacts.require("StakeContract");

module.exports = function (deployer) {
  deployer.deploy(StakeContract);
};
