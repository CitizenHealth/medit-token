const MeditToken = artifacts.require('./MeditToken.sol');
const CHMeditPool = artifacts.require('./CHMeditPool.sol');

module.exports = function(deployer) {
  deployer.deploy(CHMeditPool, MeditToken.address);
}
