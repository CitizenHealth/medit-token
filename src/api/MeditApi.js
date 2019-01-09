import { default as Web3 } from 'web3';
import { default as contract } from 'truffle-contract';
import { default as HDWalletProvider} from 'truffle-hdwallet-provider';
import { default as fs } from 'fs';
import { default as config } from '../config.json';

import HumantivMeditPoolContract from '../build/contracts/HumantivMeditPool.json';

var web3 = new Web3(new HDWalletProvider(config.mnemonic, `https://ropsten.infura.io/${config.infurakey}`, config.account));

var HumantivMeditPool = contract(HumantivMeditPoolContract);
HumantivMeditPool.setProvider(web3.currentProvider);

var accounts;
var account;

var setAccounts = function() {
  web3.eth.getAccounts(function(err, accs) {
    if (err != null) {
      console.log("There was an error fetching your accounts." + err);
      return;
    }
    
    if (accs.length == 0) {
      console.log("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      return;
    }
    
    accounts = accs;
    account = accounts[0]; 
  });
  console.log("accounts set")
}

setAccounts();

module.exports = {
  totalMedit : function() {
    return HumantivMeditPool.deployed()
      .then(contract => contract.totalMedit.call({from: account}))
  },

  humantivMedit : function() {
    return HumantivMeditPool.deployed()
      .then(contract => contract.humantivMedit.call({from: account}))
  },

  requestIssuance : function(value) {
    return HumantivMeditPool.deployed()
      .then(contract => contract.requestIssuance(value, {from: account}))
  },

  issueMedit : function(to, value) { // need to deal with error
    return HumantivMeditPool.deployed()
      .then(contract => contract.issueMedit(to, value, {from: account}))
  },

  getReleaseAmount : function() {
    return HumantivMeditPool.deployed()
      .then(contract => contract.releaseAmount_.call({from: account}))
  },

  getReleaseTime : function() {
    return HumantivMeditPool.deployed()
      .then(function(contract) {
        this.contract = contract;
      })
      .then(() => this.contract.releaseRequestTime_.call({from: account}))
      .then(function(time) {
        this.requestTime = time;
        return this.contract.releaseTimeLock_.call({from: account});
      })
      .then(function(lock) {
        Math.max(0, lock - ((new Date().getTime() / 1000) - 
                            this.requestTime))
      })
  }
}

