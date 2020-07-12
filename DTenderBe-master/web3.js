import Web3 from 'web3';

let web3;

if (typeof window !== 'undefined' && typeof window.web3 !== 'undefined') {
    //We are in the browser with metamask
    web3 = new Web3(window.web3.currentProvider);
} else {
    //We are not on the browser or the user is not running metamask
    const provider = new Web3.providers.HttpProvider("https://rinkeby.infura.io/v3/3cae9a9c53114cb4b72e78d611979cd5");
    web3 = new Web3(provider);
}

export default web3;