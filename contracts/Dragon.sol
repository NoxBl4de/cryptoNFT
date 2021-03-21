pragma solidity ^0.7.6;

import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '../node_modules/@openzeppelin/contracts/math/Math.sol';
import '../node_modules/@openzeppelin/contracts/math/SafeMath.sol';

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

    function exist(uint256 tokenId) public returns(bool) {
        return _exists(tokenId);
    }
    
    function random(uint256 modulo) public returns (uint256) {
      return SafeMath.mod(uint(keccak256(abi.encodePacked(
            blockhash(block.number - 1),
            block.timestamp
        ))), modulo);
    }
   


    function declareAnimal() public onlyAllowed notZeroAddress returns(bool) {
    // call _mint
        metadataGenerator();
        _safeMint(msg.sender, _numToken);
        _numToken += 1;
        return true;
    }

    function metadataGenerator() private returns(bool){
        Element elem = Element(random(uint(Element.GROUND)));
        bool gender = random(2) == 0 ? true : false;
        uint256 defense = random(5);
        uint256 attack = SafeMath.add(10, random(10));
        uint256 hp = SafeMath.add(50, random(50));
        uint256 init = random(100);
        Characteristics memory randomCharac = Characteristics(elem, gender, defense, attack, hp, init);
        metadata[_numToken] = randomCharac;
        return true;
    }



    function deadAnimal(uint256 _tokenId) public onlyAllowed returns(bool) {
        // call _burn
        _burn(_tokenId);
        return true;
    }



    function breedAnimal(uint256 _tokenId1, uint256 _tokenId2) public onlyAllowed notZeroAddress {
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
    modifier onlyAllowed()  {
        require(allowedBreeders[msg.sender], "Allowed: user is not allowed to call this function");
        _;
    }

    modifier notZeroAddress() {
        require(msg.sender != address(0), "ERC721: balance query for the zero address");
        _;
    }
}