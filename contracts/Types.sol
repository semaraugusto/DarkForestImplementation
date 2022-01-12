pragma solidity ^0.8.10;

library Types {
    struct Planet {
        uint timestamp_last_spawn;
        uint num_players_occupying;
        bool initialized;
        uint remaining_resources;
        uint gathered_resources;
        uint resources_per_turn;
    }
    struct Player {
        uint curr_pos;
        uint timestamp_last_move;
        uint total_resources;
    }
}
