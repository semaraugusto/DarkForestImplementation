pragma solidity ^0.8.10;

// import "./MerkleTree.sol";
import "./Types.sol";

// interface IVerifier {
//     function verifyProof(
//             uint[2] memory a,
//             uint[2][2] memory b,
//             uint[2] memory c,
//             uint[1] memory input
//         ) external returns (bool r);
// }

/// @title Voting with delegation.
library Planet {
    function getPlanetType(uint planet_hash) public pure returns(uint) {
        uint type_id;
        if (planet_hash % 3 == 0) {
            if (planet_hash % 5 == 0) {
                if(planet_hash % 7 == 0) {
                    type_id = 3;
                } else {
                    type_id = 2;
                }
            } else {
                type_id = 1;
            }
        } else {
            type_id = 0;
        }
        return type_id;
    }
}
