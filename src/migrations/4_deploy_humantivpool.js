const MeditToken = artifacts.require('./MeditToken.sol');
const HumantivMeditPool = artifacts.require('./HumantivMeditPool');

module.exports = function(deployer) {
  deployer.deploy(HumantivMeditPool, MeditToken.address, 60);
}
