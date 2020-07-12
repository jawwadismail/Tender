const HDWalletProvider = require("truffle-hdwallet-provider");
const Web3 = require('web3');
const compiledFactory = require('../ethereum/build/TenderFactory.json');

const provider = new HDWalletProvider(
    "unable review margin trick gadget reason advance tortoise young fruit upper umbrella",
    "https://rinkeby.infura.io/v3/3cae9a9c53114cb4b72e78d611979cd5"
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    console.log(`Attempting to deploy from account ${accounts[0]}`);

    const result = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
        .deploy({
            data: compiledFactory.bytecode
        })
        .send({
            gas: "5000000",
            from: accounts[0]
        });
    console.log(`Contract deployed to ${result.options.address}`);
};
deploy();