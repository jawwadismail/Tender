pragma solidity ^0.4.17;
pragma experimental ABIEncoderV2;

contract TenderFactory{
    address[] public deployedTenders;
    
    function createTender(string tenderTitle,string industry,string description,uint bidO,uint bidC, string documents) public{
        address newTender = new Tender(msg.sender,tenderTitle,industry,description,bidO,bidC,documents);
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
        uint bidStatus; //0 => pending; 1 => verified; 2 => negotiate; 3 => rejected
    }
    
    Bid[] bids;
    address public manager;
    string public tenderTitle;
    string public industry;
    string public description;
    string public documents;
    uint public bidO;
    uint public bidC;
    bool public complete;
    uint finalTenderAmount;
    address winningCompany;
    string finalTenderClause;
    mapping(address => bool) bidders;
    mapping(address => uint) bidderToBid;
    uint biddersCount;
    
    
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }
    
    constructor(address _manager,string _tenderTitle,string _industry,string _description,uint _bidO,uint _bidC,string _documents) public{
        manager = _manager;
        tenderTitle = _tenderTitle;
        industry = _industry;
        description  = _description;
        bidO = _bidO;
        bidC = _bidC;
        documents = _documents;
    }
    
    function getTenderDetails() public view returns(address,string,string,string,string,uint,uint,bool){
        return (manager,tenderTitle,industry,description,documents,bidO,bidC,complete);
    }
    
    function createBid(uint _quotationAmount,string _quotationClause,string _companyDocuments) public {
        require(now > bidO);
        require(now < bidC);
        require(!complete);
        require(!bidders[msg.sender]);
        
        Bid memory newBid = Bid({
            companyAddress: msg.sender,
            quotationAmount: _quotationAmount,
            quotationClause: _quotationClause,
            companyDocuments: _companyDocuments,
            bidStatus: 0
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
        bids[index].bidStatus = 1;
    }
    
    function rejectBid(uint index) public restricted{
        bids[index].bidStatus = 3;
    }
    
    function getBidStatus() public view returns(uint){
        require(now > bidC);
        uint index = bidderToBid[msg.sender];
        return bids[index].bidStatus;
    }
    
    function initNegotiation(uint index) public restricted{
        bids[index].bidStatus = 2;
    }
    
    function updateBidToNegotiate(uint index, uint _quotationAmount,string _quotationClause) public{
        require(bids[index].companyAddress == msg.sender);
        require(now > bidC);
        require(bids[index].bidStatus == 2);
        require(!complete);
        
        bids[index].quotationAmount = _quotationAmount;
        bids[index].quotationClause = _quotationClause;
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
    
    function releaseBids() public view returns(Bid[]){
        require(complete);
        return bids;
    }
    
}