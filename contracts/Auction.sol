pragma solidity ^0.7.6;

import './Dragon.sol';
import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract Auction {

    struct AuctionStruct {
        address seller;
        address bidder;
        uint256 startingPrice;
        uint256 immediatBuyingPrice;
        uint currentPrice;
        uint256 deadline;
    }

    // keep track of the nb of auctions created
    uint256 public nbAuction;
    Dragon instanceofDragon;
    // mapping the tokenId with the auction struct
    mapping (uint256 => Auction) public auctions;
    mapping (uint256 => bool) public activeAuctions;
    
    constructor() {
        nbAuction = 0;
        instanceofDragon = Dragon(msg.sender);
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
    /** @dev Create an auction for a specific ERC721 token
      * @param tokenId_ id of the ERC721 token
      * @param startingPrice_ starting price for the auction
      * @param immediatBuyingPrice_ immediat buying price
      * @return success whether the function succeded or not
      */
    function createAuction(uint256 tokenId_, uint256 startingPrice_, uint256 immediatBuyingPrice_ ) public activeAuction(tokenId_) returns(bool) {
        require(instanceofDragon._exists(tokenId_), 'This tokenId does not belong to this address');
        require(instanceofDragon.ownerOf(tokenId_) == msg.sender, 'The token does not belong to you');
        activeAuctions[tokenId_] = true;
        AuctionStruct memory auction = AuctionStruct(msg.sender, msg.sender, startingPrice_, immediatBuyingPrice_, startingPrice_, now + (2 * 1 days) );
        auctions[tokenId_] = auction;
        nbAuction += 1;
        return true;
    }
    
    //
    // Checks if the auction is still live
    // Checks if the amount entered is higher than the amount bidded
    // Returns true if the bid is placed, no if not
    //
    /** @dev options for the bidder to bid on token ERC721
      * @param _tokenId id of the ERC721 token
      * @param _amount amount to bid
      * @return success whether the function succeded or not
      */
    function bidOnAuction(uint256 _tokenId, uint256 _amount) public activeAuction(_tokenId) returns(bool) {
        auctions[_tokenId].bidder = msg.sender;
        auctions[_tokenId].currentPrice = _amount;
        return true;
    }

    //
    // Enables the buyer to buy the token instantly
    // if 0 then no immediat buying price
    //

    /** @dev Options for the buyers to buy on predetermined price
      * @param tokenId id of the ERC721 token
      * @return success whether the function succeded or not
      */
    function immediatBuy(uint256 tokenId) public activeAuction(tokenId) returns(bool) {
        // requirements for instant buying the token, without using the auction
        require(auctions[tokenId].immediatBuyingPrice > 0, 'No immediat buying price');
        require(auctions[tokenId].immediatBuyingPrice == msg.value, 'The price must be exact');
        instanceofDragon.safeTransferFrom(auctions[tokenId].seller, msg.sender, tokenId);
        // send eth to the seller from the buyer
        auctions[tokenId].transfer(msg.value);
        activeAuctions[tokenId] = false;
    }
    
    
    /** @dev after 2 days of auction, the highest bidder can claim the token, The contract verifies that the token is off the auctions and that the address claiming the token is the one that won the auction.
      * @param from address of the token holder.
      * @param to address of the winner bidder.
      * @param tokenId tokenId of the ERC721
      * @return success whether the function succeded or not
      */
    function claimAuction(address payable from, address to, uint256 tokenId) public payable activeAuction(tokenId) returns(bool success) {
        
        // requirements for claiming the token
        require(    msg.sender == auctions[tokenId].bidder, 
                    'you must be the bidder in order to execute this function');
        require(    auctions[tokenId].deadline < now, 
                    'the auction is not finished yet');
        require(    msg.value == auctions[tokenId].currentPrice, 
                    'the amount must be the exact price');
        
        // sending the token
        instanceofDragon.safeTransferFrom(auctions[tokenId].seller, auctions[tokenId].bidder, tokenId);
        // paying the seller
        auctions[tokenId].seller.transfer(msg.value);
        activeAuctions[tokenId] = false;
    }

    // Send ETH to the contract address
    receive() external payable {

    }

}