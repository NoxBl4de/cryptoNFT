# cryptoNFT

Ce projet est divisé en 3 contrats.

* Dragon qui hérite de ERC721 par OpenZeppelin
* Auction qui permet de gérer les mises aux enchères
* Arena qui permet de gérer les combats entre dragons

---

## Dragon

Création de token NFT ERC-721.

On fait hériter le token de l'interface fournie par OpenZeppelin.
Les fonctions codées en plus permettent de customiser le NFT, en rajoutant des metadatas notamment pour les caractéristiques du dragon.

* `breedAnimals`
* `deadAnimals` 
* `createAnimals`

## Auction

Il est possible de créer une enchère à partir d'un token ERC 721 que l'on possède.

Il y a un prix d'enchère et un prix d'achat immediat.
Si le vendeur souhaite vendre son token, il peut à la fois mettre un prix d'enchere et un prix d'achat immédiat. 

## Arena

Les tokens peuvent se combattre, un seul survit et l'autre est détruit.