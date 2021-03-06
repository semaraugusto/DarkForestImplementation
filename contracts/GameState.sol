pragma solidity ^0.8.10;

// import "./MerkleTree.sol";
import "./Planet.sol";
import "./Types.sol";

interface sVerifier {
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) external returns (bool r);
}
interface mVerifier {
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[2] memory input
        ) external returns (bool r);
}

/// @title Voting with delegation.
contract GameState {
    uint32 min_spawn_distance; 
    uint32 max_spawn_distance; 
    uint initialized_planets_count;
    // MerkleTree tree;
    event Spawn(string data, address player_addr, uint _input, uint timestamp);
    event Moved(string data, address player_addr, uint _input, uint timestamp);
    event CollectedInplace(string data, address player_addr, uint _input, uint timestamp);
    event InitializedPlanet(string data, address player_addr, uint _input, uint timestamp);
    event Log(string data, uint planet_type);
    event InitPlanet(string data, Types.Planet planet);
    event Collected(uint amount);
    event Info(string data);
    using Planet for Types.Planet;

    mapping(uint => Types.Planet) planets;
    mapping(address => Types.Player) players;
    sVerifier spawn_verifier;
    mVerifier move_verifier;

    constructor(address _spawn_verifier_addr, address _move_verifier_addr, uint32 _min_distance, uint32 _max_distance) {
        // tree = new MerkleTree(20);
        min_spawn_distance = _min_distance;
        max_spawn_distance = _max_distance;
        spawn_verifier = sVerifier(_spawn_verifier_addr);
        move_verifier = mVerifier(_move_verifier_addr);
    }

    function initializePlanet(uint _planet_type, Types.Planet storage _planet) internal returns(bool) {
        _planet.initialized = true;
        initialized_planets_count += 1;
        emit Log("Planet type", _planet_type);
        if(_planet_type == 0) {
            _planet.resources_per_turn = 0;
            _planet.remaining_resources = 0;

        } else if(_planet_type == 1) {
            _planet.remaining_resources = 1000;
            _planet.resources_per_turn = 10;
        } else if(_planet_type == 2) {
            _planet.remaining_resources = 10000;
            _planet.resources_per_turn = 50;
        } else if(_planet_type == 3) {
            _planet.remaining_resources = 100000;
            _planet.resources_per_turn = 150;
        } else {
            return false;
        }


        emit InitPlanet("Planet...", _planet);
        return true;
    }
    function getPlanetResources(uint _planet_type, Types.Planet memory _planet) internal view returns(Types.Planet memory) {
        if(_planet_type == 0) {
            _planet.resources_per_turn = 0;
            _planet.remaining_resources = 0;

        } else if(_planet_type == 1) {
            _planet.remaining_resources = 1000;
            _planet.resources_per_turn = 10;
        } else if(_planet_type == 2) {
            _planet.remaining_resources = 10000;
            _planet.resources_per_turn = 50;
        } else if(_planet_type == 3) {
            _planet.remaining_resources = 100000;
            _planet.resources_per_turn = 150;
        }
        return _planet;
    }

    
    function move(
        uint[2] memory _a, 
        uint[2][2] memory _b,
        uint[2] memory _c, 
        uint[2] memory _input
        ) public {
        Types.Player storage player = players[msg.sender];
        require(player.timestamp_last_move < block.timestamp - 30 seconds, "Player has moved in the last 30 seconds. Please wait a little longer.");
        require(player.curr_pos != uint(0), "Player has not spawned yet.");

        // collecting resources on current planet

        bool valid = move_verifier.verifyProof(_a, _b, _c, _input);
        require(valid, "proof not valid");

        require(_input[0] == player.curr_pos, "Stop cheating you filthy cheater....");

        player.timestamp_last_move = block.timestamp;

        // Inplace collection
        if (_input[1] == player.curr_pos){
            Types.Planet storage planet = planets[_input[1]];
            planet.gathered_resources += planet.resources_per_turn;
            planet.remaining_resources -= planet.resources_per_turn;
            emit CollectedInplace("Collected!", msg.sender, _input[1], block.timestamp);
        } else {
            // player trying to move to another planet
            Types.Planet storage planet_from = planets[player.curr_pos];
            if (planet_from.initialized == false) {
                require(false, "wtf did you do dude");
            }
            Types.Planet storage planet_to = planets[_input[1]];

            uint planet_type = Planet.getPlanetType(_input[1]);
            // require(planet_type != 0, "Not a valid planet...");

            if (planet_to.initialized == false) {
                require(initializePlanet(planet_type, planet_to) == true, "Could not initialize planet.");
            }

            // leaving planet
            require(planet_from.num_players_occupying > 0, "There are no players there wtf");
            planet_from.num_players_occupying -= 1;

            if (planet_from.resources_per_turn > 0) {
                if (planet_from.num_players_occupying == 0) {
                    player.total_resources += planet_from.gathered_resources;
                    emit Collected(planet_from.gathered_resources);
                    planet_from.gathered_resources = 0;
                }
            }
            planet_to.num_players_occupying += 1;
            // Collect resources if there are any
            if (planet_to.resources_per_turn > 0) {
                planet_to.gathered_resources += planet_to.resources_per_turn;
                planet_to.remaining_resources -= planet_to.resources_per_turn;

            }
            player.curr_pos = _input[1];
            emit Moved("Moved!", msg.sender, _input[1], block.timestamp);
        }
    }

    function spawn(
            uint[2] memory _a,
            uint[2][2] memory _b,
            uint[2] memory _c,
            uint[1] memory _input
        ) public {
        Types.Player storage player = players[msg.sender];
        require(player.curr_pos == uint(0), "Player has already spawned");
        bool valid = spawn_verifier.verifyProof(_a, _b, _c, _input);
        require(valid, "proof not valid");
        uint planet_type = Planet.getPlanetType(_input[0]);
        // require(planet_type != 0, "Not a planet.");

        Types.Planet storage planet = planets[_input[0]];
        if(planet.initialized == true) {
            require(planet.timestamp_last_spawn < block.timestamp - 1 minutes, "Player has recently spawned here!");
            require(planet.num_players_occupying == 0, "Planet is currently occupied");
        } else {
            require(initializePlanet(planet_type, planet) == true, "Could not initialize planet");
        }

        planet.timestamp_last_spawn = block.timestamp;
        planet.num_players_occupying = 1;

        player.curr_pos = _input[0];
        emit Spawn("Spawned!", msg.sender, _input[0], block.timestamp);
    }

    function getPlayer(address player_addr) public view returns(Types.Player memory) {
        return players[player_addr];
    }
    function getPlanet(uint addr) public view returns(Types.Planet memory) {
        Types.Planet memory planet = planets[addr];
        if(planet.initialized==true){
            return planet;
        }
        
        return getPlanetResources(addr, planet);
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
