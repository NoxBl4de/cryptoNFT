pragma solidity ^7.6.0

import 'C:\Users\Hugo\dev\cryptoNFT\node_modules\@openzeppelin\contracts\token\ERC721\ERC721.sol'

contract Dragon is ERC721 {

    using SafeMath for uint;
    using Math;

    uint256 private _numToken;

    mapping (address => bool) public allowedBreeders;
    
    // uint256 == tokenId
    mapping (uint256 => Characteristics) public metadata;
    
    enum Element{ FIRE, WATER, ELECTRICAL, DARKNESS, AIR, GROUND }
    
    struct Characteristics {
        Element elem; //element entre 1 et 8
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


    
    function random(uint256 modulo) private view returns (uint8) {
      return uint8(SafeMath.mod(uint256(keccak256(block.timestamp, block.difficulty), modulo);
    }
   


    function declareAnimal() public onlyAllowed notZeroAddress returns(bool) {
    // call _mint
        metadata[_numToken] = metadataGenerator();
        _safeMint(msg.sender, _numToken);
        return true;
    }

    function metadataGenerator() public returns(Characteristics){
      Element elem = random(Element.Last);
      bool gender = random(2);
      uint256 defense = random(10);
      uint256 attack = random(10);
      uint256 hp = random(100);
      uint256 init = random(100);
      Characteristics memory randomCharac = Characteristics(elem, gender, defense, attack, hp, init);
      return randomCharac;
    }



    function deadAnimal(uint256 _tokenId) public returns(bool) onlyAllowed {
    // call _burn
        _burn(_tokenId);
        return true;
    }



    function breedAnimal(_tokenId1, _tokenId2) public onlyAllowed {
      Element elem = metadata[_tokenId1].elem;
      bool gender = random(2);
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
        require(msg.sender != address(0), "ERC721: balance query for the zero address")
        _;
    }
}

contract Auction is Dragon {

    struct Auction {
        address seller;
        address bidder
        uint256 startingPrice;
        uint256 immediatBuyingPrice;
        uint currentPrice;
        uint256 deadline;
    }
    
    // mapping the tokenId with the auction struct
    mapping (uint256 => Auction) public auctions;
    mapping (uint256 => bool) public activeAuctions;
    constructor Auction() {
        
    }

    modifier validAddress() {
        require()
    }

    modifier activeAuction(uint256 tokenId) {
        require(!activeAuctions[tokenId], 'The auction is not active');
        _;
    }

    // 
    //  
    function createAuction(uint256 tokenId_, address payable seller_, uint256 startingPrice_, uint256 immediatBuyingPrice_) public activeAuction(tokenId_) returns(bool) {
        require(_exists(tokenId_), 'This tokenId does not belong to this address');
        require(ownerOf(tokenId_) == seller, 'The token does not belong to you');
        activeAuctions[tokenId_] = true;
        auctions[tokenId_] = Auction(seller_, seller_, startingPrice_, immediatBuyingPrice_, startingPrice_, now + (2 * 1 days) );
        return true;
    }
    
    // Checks if the auction is still live
    // Checks if the amount entered is higher than the amount bidded
    // Returns true if the bid is placed, no if not
    function bidOnAuction(uint256 _tokenId, address _bidder, uint256 _amount) public activeAuction(_tokenId) returns(bool) {
        auctions[tokenId_].bidder = _bidder;
        auctions[tokenId_].currentPrice = _amount;
        return true;
    }

    // after 2 days of auction, the highest bidder can claim the token
    function claimAuction(address from, address to, uint256 tokenId) public returns(bool) {
        require(auctions[tokenId].deadline < now, 'the auction is not finished yet');
        safeTransferFrom(auctions[tokenId].seller, auctions[tokenId].bidder, tokenId)
    }

}

contract Arena {

    constructor Arena() {

    }

    // choose a dragon to fight and chose an amount to stake
    function proposeToFight(uint256 tokenId, uint256 stake) {
        
    }

    // Staking the same amount as the proposing address
    function agreeToFight(uint256 stake) {
        
    }
    
    // fighter represents the tokenId of the dragon
    function fight(uint256 fighter_1, uint256 fighter_2) returns(uint256 winner) {
        
    }
}