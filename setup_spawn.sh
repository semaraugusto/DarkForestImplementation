circom circuits/spawn/spawn.circom --r1cs --wasm --sym --c

cd spawn_js;
node generate_witness.js spawn.wasm ../input_spawn_suc.json ../witness_spawn.wtns

cd ../
# snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
# snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
# snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

snarkjs groth16 setup spawn.r1cs pot12_final.ptau circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey spawn.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey spawn.zkey spawn_verification_key.json

snarkjs groth16 prove spawn.zkey witness_spawn.wtns proof_spawn.json public_spawn.json
snarkjs groth16 verify spawn_verification_key.json public_spawn.json proof_spawn.json
snarkjs zkey export solidityverifier spawn.zkey spawnverifier.sol

echo "$(snarkjs zkey export soliditycalldata public_spawn.json proof_spawn.json)" &> ./tmp/calldata

cat ./tmp/calldata
