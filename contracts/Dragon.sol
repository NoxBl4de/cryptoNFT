pragma solidity ^0.7.6;

import 'C:\Users\Hugo\dev\cryptoNFT\node_modules\@openzeppelin\contracts\token\ERC721\ERC721.sol';
import 'C:\Users\Hugo\dev\cryptoNFT\node_modules\@openzeppelin\contracts\math\Math.sol';
import 'C:\Users\Hugo\dev\cryptoNFT\node_modules\@openzeppelin\contracts\math\SafeMath.sol';

contract Dragon is ERC721 {

    using SafeMath for uint;
    using Math for uint;

    uint256 private _numToken;

    mapping (address => bool) public allowedBreeders;
    
    // uint256 == tokenId
    mapping (uint256 => Characteristics) public metadata;
    
    enum Element{ FIRE, WATER, ELECTRICAL, DARKNESS, AIR, GROUND }
    
    struct Characteristics {
        Element elem; //element entre 1 et 6
        bool male; // 0 F / 1 M
        uint256 defense;
        uint256 attack;       
        uint256 hp; 
        uint256 init;
    }   
    
    constructor() ERC721 ("Dragon", "DRG"){ 
        _numToken = 0;
    }

    function registerBreed() public notZeroAddress returns(bool) {
        allowedBreeders[msg.sender] = true;
        return true;
    }


    
    function random(uint256 modulo) internal view returns (uint8) {
      return uint8(SafeMath.mod(uint256(keccak256(block.timestamp, block.difficulty), modulo)));
    }
   


    function declareAnimal() public onlyAllowed notZeroAddress returns(bool) {
    // call _mint
        metadata[_numToken] = metadataGenerator();
        _safeMint(msg.sender, _numToken);
        _numToken += 1;
        return true;
    }

    function metadataGenerator() public returns(Characteristics){
        Element elem = random(Element.Last);
        bool gender = random(2) == 0 ? true : false;
        uint256 defense = random(10);
        uint256 attack = random(10);
        uint256 hp = random(100);
        uint256 init = random(100);
        Characteristics memory randomCharac = Characteristics(elem, gender, defense, attack, hp, init);
        return randomCharac;
    }



    function deadAnimal(uint256 _tokenId) public onlyAllowed returns(bool) {
        // call _burn
        _burn(_tokenId);
        return true;
    }



    function breedAnimal(_tokenId1, _tokenId2) public onlyAllowed notZeroAddress {
        require(ownerOf(_tokenId1) == ownerOf(_tokenId2), 'both token must be from the same token holder in order to be bred');
        Element elem = metadata[_tokenId1].elem;
        bool gender = random(2) == 0 ? true : false;
        uint256 defense = Math.average(metadata[_tokenId1].defense, metadata[_tokenId2].defense);
        uint256 attack = Math.average(metadata[_tokenId1].attack, metadata[_tokenId2].attack);
        uint256 hp = Math.average(metadata[_tokenId1].hp, metadata[_tokenId2].hp);
        uint256 init = Math.average(metadata[_tokenId1].init, metadata[_tokenId2].init);
        Characteristics memory randomCharac = Characteristics(elem, gender, defense, attack, hp, init);
    }

    
    /**
     * @dev Throws if called by any account other than the allowed ones.
     */
    modifier onlyAllowed() {
        require(allowedBreeders[msg.sender], "Allowed: user is not allowed to call this function");
        _;
    }

    modifier notZeroAddress() {
        require(msg.sender != address(0), "ERC721: balance query for the zero address");
        _;
    }
}

contract Auction {

    struct Auction {
        address seller;
        address bidder;
        uint256 startingPrice;
        uint256 immediatBuyingPrice;
        uint currentPrice;
        uint256 deadline;
    }

    // keep track of the nb of auctions created
    uint256 public nbAuction;
    
    // mapping the tokenId with the auction struct
    mapping (uint256 => Auction) public auctions;
    mapping (uint256 => bool) public activeAuctions;
    
    constructor() Auction() {
        nbAuction = 0;
    }

    modifier activeAuction(uint256 tokenId) {
        require(activeAuctions[tokenId], 'The auction is not active');
        _;
    }

    // 
    //  Creating an action based on the criteria defined by the user
    //  If immediatBuyingPrice is equal to 0, then the buyers cannot buy the token immediatly
    //  They must bid
    //
    function createAuction(uint256 tokenId_, address payable seller_, uint256 startingPrice_, uint256 immediatBuyingPrice_ ) public activeAuction(tokenId_) returns(bool) {
        require(Dragon._exists(tokenId_), 'This tokenId does not belong to this address');
        require(Dragon.ownerOf(tokenId_) == seller, 'The token does not belong to you');
        activeAuctions[tokenId_] = true;
        Auction memory auction = Auction(seller_, seller_, startingPrice_, immediatBuyingPrice_, startingPrice_, now + (2 * 1 days) );
        auctions[tokenId_] = auction;
        nbAuction += 1;
        return true;
    }
    
    //
    // Checks if the auction is still live
    // Checks if the amount entered is higher than the amount bidded
    // Returns true if the bid is placed, no if not
    //
    function bidOnAuction(uint256 _tokenId, address _bidder, uint256 _amount) public activeAuction(_tokenId) returns(bool) {
        auctions[tokenId_].bidder = _bidder;
        auctions[tokenId_].currentPrice = _amount;
        return true;
    }

    //
    // Enables the buyer to buy the token instantly
    // if 0 then no immediat buying price
    //
    function immediatBuy(uint256 tokenId, address buyer, uint256 amount_) public activeAuction(_tokenId) returns(bool) {
        // requirements for instant buying the token, without using the auction
        require(auctions[tokenId].immediatBuyingPrice > 0, 'No immediat buying price');
        require(auctions[tokenId].immediatBuyingPrice == amount_, 'The price must be exact');
        Dragon.safeTransferFrom(auctions[tokenId].seller, buyer, tokenId);
        // send eth to the seller from the buyer
        Dragon.safeTransfertFrom(buyer, auctions[tokenId].seller, amount_);
        activeAuctions[tokenId] = false;
    }
    
    //
    //  after 2 days of auction, the highest bidder can claim the token
    //  The contract verifies that the token is off the auctions and that the address claiming the token is the one that won the auction.
    //
    function claimAuction(address payable from, address to, uint256 tokenId) public payable activeAuction(_tokenId) returns(bool) {
        
        // requirements for claiming the token
        require(    msg.sender == auctions[tokenId].bidder, 
                    'you must be the bidder in order to execute this function');
        require(    auctions[tokenId].deadline < now, 
                    'the auction is not finished yet');
        require(    msg.value == auctions[tokenId].currentPrice, 
                    'the amount must be the exact price');
        
        // sending the token
        Dragon.safeTransferFrom(auctions[tokenId].seller, auctions[tokenId].bidder, tokenId);
        // paying the seller
        auctions[tokenId].seller.transfer(msg.value);
        activeAuctions[tokenId] = false;
    }

    // Send ETH to the contract address
    function receive() external payable {

    }

}

contract Arena {

    // tokenId => addressFighter
    mapping (uint256 => address) public userToken;

    struct Fight {
        uint256 fighter_1;
        uint256 fighter_2;
        uint256 stake;
    }

    uint256[] private proposals;
    // Counts the number of fight proposals
    uint256 private cptProposal = 0;

    constructor() Arena() {
    }

    // choose a dragon to fight and chose an amount to stake
    function proposeToFight(uint256 tokenId, uint256 stakeProposed) public Dragon.onlyAllowed {
        proposals.push((cptProposal, tokenId, stakeProposed));

        userToken[tokenId] = msg.sender;

        cptProposal += 1;
    }

    // Staking the same amount as the proposing address
    // Check the proposals with getProposals
    // Chooses one with the index and launches the fight
    function agreeToFight(uint256 indexProposal, uint256 tokenId) public Dragon.onlyAllowed {
        uint256 index, fighter_1, stake;
        
        (index, fighter_1, stake) = proposals[indexProposal];
        
        Fight memory newFight = Fight(fighter_1, tokenId, stake);

        userToken[tokenId] = msg.sender;
        
        fight(newFight);
        
    }
    
    // fighter represents the tokenId of the dragon
    function fight(Fight fight) private payable returns(uint256 winner) {
        
        

    }
    
    function getProposals() public returns(uint256[] proposal) {
        return proposals;
    }
}