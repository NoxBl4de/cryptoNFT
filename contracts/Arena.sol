pragma solidity ^0.7.6;

import './Dragon.sol';
import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';


contract Arena {

    // tokenId => addressFighter
    mapping (uint256 => address payable) public userToken;

    struct Fight {
        uint256 fighter_1;
        uint256 fighter_2;
        uint256 stake;
    }
    Dragon instanceofDragon;
    
    uint256 fighter;
    uint256 stake;

    constructor() {
        instanceofDragon = Dragon(msg.sender);
    }

    // choose a dragon to fight and chose an amount to stake
    function proposeToFight(uint256 tokenId, uint256 stakeProposed) public {
        fighter = tokenId;
        stake = stakeProposed;

        userToken[tokenId] = msg.sender;
    }

    // Staking the same amount as the proposing address
    // Check the proposals with getProposals
    // Chooses one with the index and launches the fight
    function agreeToFight(uint256 tokenId) public {

        require(userToken[fighter] != msg.sender, "You cannot fight your own dragon !");
        
        Fight memory newFight = Fight(fighter, tokenId, stake);

        userToken[tokenId] = msg.sender;
        
        combat(newFight);
        
    }
    
    // Make two dragons fight
    // The result of the fight is random and the loser dies
    function combat(Fight memory fight) internal returns(uint256) {

        uint8 res = uint8(instanceofDragon.random(2));
        uint256 winner;

        if (res == 0) {
            winner = fight.fighter_1;
            instanceofDragon.deadAnimal(fight.fighter_2);
        }

        else {
            winner = fight.fighter_2;
            instanceofDragon.deadAnimal(fight.fighter_1);
        }

        userToken[winner].transfer(fight.stake*2);

        return winner;
    }
}