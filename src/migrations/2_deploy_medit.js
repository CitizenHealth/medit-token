const MeditToken = artifacts.require('./MeditToken.sol');

module.exports = function(deployer) {
  deployer.deploy(MeditToken);
}
