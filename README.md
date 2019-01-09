# Citizen Health Medit Token

## Setup

A config.json file is needed at src/config.json with 3 values

```javascript
{
  "infurakey" : "0123abc...",
  "mnemonic" : "twelve word phrase space separated...",
  "account" : 0
}
```

Infura key is needed to interact with on-chain contracts. Key can be obtained for free at [infura.io](https://infura.io/) (register, then create a project). The mnemonic is used to generate an Ethereum wallet account. A twelve word phrase is needed. One way to generate is to export from MetaMask (**warning** - phrase will give access to all associated accounts, so do not use one associated with significant funds). The account variable is the account index of the wallet to use (0-indexed). Use 0 if you only have one account. config.json is excluded from git commits so you will need to create it.


## Deployment

*At present* the best stratergy is to deploy your own instance of the contracts to the network (currently only set up for the Ropsten network). To do this you will need the [truffle framework](https://truffleframework.com/truffle) installed.

```bash
$ cd src/
$ truffle compile
$ truffle migrate --network ropsten
```

## API

To build

```bash
$ npm run build
```

Usage

```javascript
var api = require('../build/MeditApi.js')

// total medit supply
api.totalMedit().then(total => console.log("total = " + total)

// humantiv contract medit supply
api.humantivMedit().then(total => console.log("total = " + total)

// request issuance (i.e. request porttion of supply of medit to distribute)
// 100 in this case
api.requestIssuance(100).then(() => console.log("request processed..."))

// check the amount available for release (e.g. 100)
api.getReleaseAmount().then(n => console.log(n + " medit available for distribution"))

// get time remaining until issuance is released 
// if 0 then issuance is available to distribute
api.getReleaseTime().then(t => console.log(t + " seconds until release"))

// distribute funds (to e.g. 0x3637E4282EE5ED9dcCFc4b4e1aBA766B40A832B8)
api.issueMedit("0x3637E4282EE5ED9dcCFc4b4e1aBA766B40A832B8", 50)
   .then(() => console.log("medit issued"))
```