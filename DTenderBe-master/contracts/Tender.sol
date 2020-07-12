pragma solidity ^0.4.17;
pragma experimental ABIEncoderV2;

contract TenderFactory{
    address[] public deployedTenders;
    
    function createTender(string tenderTitle,string industry,string description,uint bidO,uint bidC) public{
        address newTender = new Tender(msg.sender,tenderTitle,industry,description,bidO,bidC);
        deployedTenders.push(newTender);
    }
    
    function getDeployedTenders() public view returns (address[]){
        return deployedTenders;
    }
}

contract Tender{
    
    struct Bid{
        address companyAddress;
        uint quotationAmount;
        string quotationClause;
        string companyDocuments;
        bool bidStatus; //true => verified; false => rejected
    }
    
    Bid[] bids;
    address public manager;
    string public tenderTitle;
    string public industry;
    string public description;
    uint public bidO;
    uint public bidC;
    bool public complete;
    uint finalTenderAmount;
    address winningCompany;
    string finalTenderClause;
    mapping(address => bool) bidders;
    mapping(address => uint) bidderToBid;
    uint biddersCount;
    uint public noww;
    
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }
    
    constructor(address _manager,string _tenderTitle,string _industry,string _description,uint _bidO,uint _bidC) public{
        manager = _manager;
        tenderTitle = _tenderTitle;
        industry = _industry;
        description  = _description;
        bidO = _bidO;
        bidC = _bidC;
    }
    
    function getTenderDetails() public view returns(address,string,string,string,uint,uint,bool){
        return (manager,tenderTitle,industry,description,bidO,bidC,complete);
    }
    
    function createBid(uint _quotationAmount,string _quotationClause,string _companyDocuments) public {
        noww = now;
        require(now > bidO);
        require(now < bidC);
        require(!complete);
        require(!bidders[msg.sender]);
        
        Bid memory newBid = Bid({
            companyAddress: msg.sender,
            quotationAmount: _quotationAmount,
            quotationClause: _quotationClause,
            companyDocuments: _companyDocuments,
            bidStatus: false
        });
        
        bids.push(newBid);
        bidderToBid[msg.sender] = bids.length - 1;
        bidders[msg.sender] = true;
        biddersCount++;
    }
    
    function getBids() public view restricted returns (Bid[]){
        require(now > bidC);
        return bids;
    }
    
    function approveBid(uint index) public restricted{
        bids[index].bidStatus = true;
    }
    
    
    function selectWinner(uint index) public restricted{
        require(now > bidC);
        winningCompany = bids[index].companyAddress;
        finalTenderAmount = bids[index].quotationAmount;
        finalTenderClause = bids[index].quotationClause;
        complete = true;
    }
    
    function getWinningDetails() public view returns(uint,string,address){
        require(complete);
        require(now > bidC);
        return (finalTenderAmount,finalTenderClause,winningCompany);
    }
    
    function getBidStatus() public view returns(bool){
        require(now > bidC);
        uint index = bidderToBid[msg.sender];
        return bids[index].bidStatus;
    }
}