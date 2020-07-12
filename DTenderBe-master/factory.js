import web3 from './web3';
import TenderFactory from './build/TenderFactory.json';

const instance = new web3.eth.Contract(
    JSON.parse(TenderFactory.interface),
    '0xBc9548522A6359cc4C9F91B4cf20d379B2275f38'
);

export default instance;