pragma solidity ^0.7.6;

import '.\Dragon.sol';
import 'C:\Users\Hugo\dev\cryptoNFT\node_modules\@openzeppelin\contracts\token\ERC721\ERC721.sol';

contract Auction is Dragon {

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
    
    constructor() Auction {
        nbAuction = 0;
    }

    modifier validAddress() {
        require();
        _;
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
        nbAuction += 1;
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

    // Enables the buyer to buy the token instantly
    // if 0 then no immediat buying price
    function immediatBuy(uint256 tokenId, address buyer, uint256 amount_) public returns(bool) {
        require(auctions[tokenId].immediatBuyingPrice > 0, 'No immediat buying price');
        require(auctions[tokenId].immediatBuyingPrice == amount_, 'The price must be exact');
        safeTransferFrom(auctions[tokenId].seller, buyer, tokenId);
        // send eth to the seller from the buyer
        safeTransfertFrom(buyer, auctions[tokenId].seller, amount_);
    }

    // after 2 days of auction, the highest bidder can claim the token
    function claimAuction(address from, address to, uint256 tokenId, uint256 amount) public payable returns(bool) {
        require(auctions[tokenId].deadline < now, 'the auction is not finished yet');
        safeTransferFrom(auctions[tokenId].seller, auctions[tokenId].bidder, tokenId);
        // send eth to the seller from the buyer
        auctions[tokenId].seller.transfer(amount);
    }

    // Send ETH to the contract address, needed to claim / buy tokens
    function receive() external payable {

    }

}