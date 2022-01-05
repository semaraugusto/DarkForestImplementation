# circom circuits/circuit.circom --r1cs --wasm --sym --c

cd circuit_js;
node generate_witness.js circuit.wasm ../input_suc.json ../witness.wtns

cd ../
# snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json
# snarkjs groth16 prove circuit_0001.zkey circuit_js/witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json

snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json
# snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol
snarkjs zkey export soliditycalldata public.json proof.json

