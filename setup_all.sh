circom circuits/spawn/spawn.circom --r1cs --wasm --sym --c

# snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
# snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
# snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

snarkjs groth16 setup spawn.r1cs pot12_final.ptau circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey spawn.zkey --name="1st Contributor Name" -v

cd spawn_js;
node generate_witness.js spawn.wasm ../input_spawn_suc.json ../witness_spawn.wtns

cd ../

snarkjs zkey export verificationkey spawn.zkey spawn_verification_key.json

snarkjs groth16 prove spawn.zkey witness_spawn.wtns proof_spawn.json public_spawn.json
snarkjs groth16 verify spawn_verification_key.json public_spawn.json proof_spawn.json
snarkjs zkey export solidityverifier spawn.zkey spawnverifier.sol

echo "$(snarkjs zkey export soliditycalldata public_spawn.json proof_spawn.json)" &> ./tmp/calldata_spawn

cat ./tmp/calldata_spawn

circom circuits/move/move.circom --r1cs --wasm --sym --c
snarkjs groth16 setup move.r1cs pot12_final.ptau circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey move.zkey --name="2st Contributor Name" -v

cd move_js;
node generate_witness.js move.wasm ../input_move_suc.json ../witness_move.wtns

cd ../
snarkjs zkey export verificationkey move.zkey move_verification_key.json

snarkjs groth16 prove move.zkey witness_move.wtns proof_move.json public_move.json
snarkjs groth16 verify move_verification_key.json public_move.json proof_move.json
snarkjs zkey export solidityverifier move.zkey moveverifier.sol

echo "$(snarkjs zkey export soliditycalldata public_move.json proof_move.json)" &> ./tmp/calldata_move

cat ./tmp/calldata_move
