pragma solidity ^0.8.10;

import "./MerkleTree.sol";

interface IVerifier {
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) external returns (bool r);
}

/// @title Voting with delegation.
contract GameState {
    uint32 min_spawn_distance; 
    uint32 max_spawn_distance; 
    MerkleTree tree;
    event Spawn(uint _input, uint timestamp);
    event Log(string data, bool valid);

    mapping(uint => Planet) Planets;
    IVerifier verifier;

    struct Planet {
        uint timestamp_last_spawn;
        bool is_occupied;
    }
    constructor(address _verifier_addr, uint32 _min_distance, uint32 _max_distance) public {
        tree = new MerkleTree(20);
        min_spawn_distance = _min_distance;
        max_spawn_distance = _max_distance;
        verifier = IVerifier(_verifier_addr);
    }
    
    function spawn(
            uint[2] memory _a,
            uint[2][2] memory _b,
            uint[2] memory _c,
            uint[1] memory _input
        ) public {
        bool valid = verifier.verifyProof(_a, _b, _c, _input);
        require(valid, "proof not valid");
        Planet storage planet = Planets[_input[0]];
        require(planet.timestamp_last_spawn < block.timestamp - 5 minutes, "Player has recently spawned here!");
        require(planet.is_occupied == false, "Planet is currently occupied");

        planet.timestamp_last_spawn = block.timestamp;
        planet.is_occupied = true;
        emit Spawn(_input[0], block.timestamp);
    }

    function getMinSpawnDistance() public view returns(uint32) {
        return min_spawn_distance;
    }
    function getMaxSpawnDistance() public view returns(uint32) {
        return max_spawn_distance;
    }
    function getDistances() public view returns(uint32[2] memory) {
        uint32[2] memory values = [min_spawn_distance, max_spawn_distance];
        return values;
    }
}
