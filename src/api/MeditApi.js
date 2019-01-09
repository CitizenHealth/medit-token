import { default as Web3 } from 'web3';
import { default as contract } from 'truffle-contract';
import { default as HDWalletProvider} from 'truffle-hdwallet-provider';
import { default as fs } from 'fs';

import HumantivMeditPoolContract from '../build/contracts/HumantivMeditPool.json';

const infuraKey = "6044524c9c914ef48641e4e2783c4240";
const mnemonic = fs.readFileSync(".secret").toString().trim();
const accountNumber = 2;

var web3 = new Web3(new HDWalletProvider(mnemonic, `https://ropsten.infura.io/${infuraKey}`, accountNumber));

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

  issueMedit : function(to, value) {
    return HumantivMeditPool.deployed()
      .then(contract => contract.issueMedit(to, value, {from: account}))
  },

  getReleaseAmount : function() {
    return HumantivMeditPool.deployed()
      .then(contract => contract.releaseAmount_({from: account}))
  },

  getReleaseRequestTime : function() {
    return HumantivMeditPool.deployed()
      .then(contract => contract.releaseRequestTime_({from: account}))
  }
}

