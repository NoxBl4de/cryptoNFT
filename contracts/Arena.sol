pragma solidity ^0.7.6;

import * as Dragon from './Dragon.sol';
import 'C:\Users\Hugo\dev\cryptoNFT\node_modules\@openzeppelin\contracts\token\ERC721\ERC721.sol';


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
    function proposeToFight(uint256 tokenId, uint256 stakeProposed) public onlyAllowed {
        proposals.push((cptProposal, tokenId, stakeProposed));

        userToken[tokenId] = msg.sender;

        cptProposal += 1;
    }

    // Staking the same amount as the proposing address
    // Check the proposals with getProposals
    // Chooses one with the index and launches the fight
    function agreeToFight(uint256 indexProposal, uint256 tokenId) public onlyAllowed {
        uint256 index;
        uint256 fighter_1;
        uint256 stake;
        
        (index, fighter_1, stake) = proposals[indexProposal];
        
        Fight memory newFight = Fight(fighter_1, tokenId, stake);

        userToken[tokenId] = msg.sender;
        
        fight(newFight);
        
    }
    
    // Make two dragons fight
    // The result of the fight is random and the loser dies
    function fight(Fight fight) private payable returns(uint256 winner) {
        
        res = Dragon.random(2);
        uint256 winner;

        if (res == 0) {
            winner = fight.fighter_1;
            deadAnimal(fight.fighter_2);
        }

        else {
            winner = fight.fighter_2;
            deadAnimal(fight.fighter_1);
        }

        userToken[winner].transfer(fight.stake*2);
    }
    
    /**
    * Returns the list of proposals to fight
     */
    function getProposals() public returns(uint256[] proposal) onlyAllowed {
        return proposals;
    }
}