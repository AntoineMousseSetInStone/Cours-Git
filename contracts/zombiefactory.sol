pragma solidity >=0.7.0 <0.8.5;
//SPDX-License-Identifier: UNLICENSEDs

import "./ownable.sol";

contract ZombieFactory is Ownable {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint coolDownTime = 1 days;

    //Structure zombies
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    //Array zombies
    Zombie[] public zombies;

    //Mapping -> Stocker et rechercher un zombie avec son Id;
    mapping (uint => address) public zombieToOwner;
    //Mapping -> Stokcer et rechercher nombre de zombie avec son address
    mapping (address => uint) ownerZombieCount;


    /*
    Goal : création de zombie + ajout dans 'zombies' Array
    In 4 Steps:
        -Step 0 : Initialisation Id du zombie
        -Step 1 : Ajout du zombie = id à msg.sender
        -Step 2 : Count nombre zombie du owner (msg.sender)
        -Step 3 : Appel event NewZombie
    Result : Nouveau zombie
    Author : Antoine Mousse
    */
    function _createZombie(string memory _name, uint _dna) internal {
        zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + coolDownTime), 0, 0));
        uint id = zombies.length - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }


     /*
    Goal : Géneration DNA aléatoire
    In 1 Steps:
        -Step 0 : Initialisation rand = hash(keccak256) du parametre _str
        -Step 1 : Retourne le resultat de rand % (10^16)
    Result : uint ADN zombie (longeur 16)
    Author : Antoine Mousse
    */
    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }


     /*
    Goal : Géneration aléatoire de zombie avec un nom passé en parametre
    In 4 Steps:
        -Step 0 : Verification que le propriétaire ne possède pas de Zombie
        -Step 1 : Déclaration randDna(uint) = resultat de _generateRandomDna() du nom passé en parametre
        -Step 2 : Ajout '00' à la fin du Dna
        -Step 3 : Appel de la fonction _createZombie avec le nom passé en paramètre et le randDna calculé juste avant
    Result : Zombie créer a partir du nom passé en paramètre + son Dna se termine par 00
    Author : Antoine Mousse
    */
    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}