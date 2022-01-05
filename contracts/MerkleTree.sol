// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf,
        uint index
    ) public pure returns (bool) {
        bytes32 hash = leaf;

        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }

            index = index / 2;
        }

        return hash == root;
    }
}

contract MerkleTree is MerkleProof {
    bytes32[] filled_subtrees;
    bytes32[] tree_leaves;
    bytes32 root;
    uint32 next_index;
    bytes32[] zeros;
    uint8 levels;
    uint32 MAX_LEAFS;
    // event LeafAdded(bytes32 leaf, uint32 leaf_index, uint256 gas_used, bytes32 new_val);
    // event Log(string data, bytes32 value);
    // event Log(string data, bytes32[] values);
    
    constructor(uint8 tree_levels) public {
        levels = tree_levels;
        next_index = 0;

        zeros.push(keccak256(abi.encodePacked("zero")));

        filled_subtrees.push(zeros[0]);

        for (uint8 i = 1; i < tree_levels; i++) {
            zeros.push(HashLeftRight(zeros[i-1], zeros[i-1]));
            filled_subtrees.push(zeros[i]);
        }
        MAX_LEAFS = uint32(2**(tree_levels-1));
        root = HashLeftRight(zeros[levels - 1], zeros[levels - 1]);
        // emit Log("Root", root);
        // emit Log("tree_leaves", tree_leaves);
    }

    function HashLeftRight(bytes32 _left, bytes32 _right) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(_left, _right)
        );
    }

    function getLeaves() external view returns (bytes32[] memory) {
        return tree_leaves;
    }
    function getSubtrees() external view returns (bytes32[] memory) {
        return filled_subtrees;
    }    
    function getRoot() external view returns (bytes32) {
        return root;
    }
    function insert_str(string memory value) public {
        bytes32 encoding = keccak256(abi.encodePacked(value));
        insert(encoding);
    }

    function insert(bytes32 _leaf) public {
        if(next_index >= MAX_LEAFS) {
            return;
        }

        uint32 current_index = next_index;
        next_index += 1;

        bytes32 current_level_hash = _leaf;
        bytes32 left;
        bytes32 right;

        bool all_were_right = true;
        for (uint8 i = 0; i < levels; i++) {
            if (current_index % 2 == 0) {
                left = current_level_hash;
                right = zeros[i];

                if(all_were_right) {
                    filled_subtrees[i] = current_level_hash;
                }
                // found left;
                all_were_right = false;
            } else {
                left = filled_subtrees[i];
                right = current_level_hash;
            }

            current_level_hash = HashLeftRight(left, right);
            current_index /= 2;
        }
        root = current_level_hash;

        tree_leaves.push(_leaf);

        // emit LeafAdded(_leaf, leaf_index, gas_used, current_level_hash);
    }
}
