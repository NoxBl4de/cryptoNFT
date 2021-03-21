pragma solidity ^0.7.6;

import 'C:\Users\Hugo\dev\cryptoNFT\node_modules\@openzeppelin\contracts\token\ERC721\ERC721.sol';


contract Arena {

    // tokenId => nbFight
    mapping(uint256 => uint256) public nbFights;
    uint256 public totalFights;

    constructor() Arena {
        totalFights = 0;
    }

    // choose a dragon to fight and chose an amount to stake
    function proposeToFight(uint256 tokenId, uint256 stake) {


        
    }

    // Staking the same amount as the proposing address
    function agreeToFight(uint256 tokenId) {
        
    }
    
    // fighter represents the tokenId of the dragon
    function fight(uint256 fighter_1, uint256 fighter_2) returns(uint256 winner) {
        
    }
}