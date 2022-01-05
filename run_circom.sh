circom circuits/circuit.circom --r1cs --wasm --sym --c

cd circuit_js
node generate_witness.js circuit.wasm ../input_suc.json ../witness.wtns
echo "witness generated"

cd ../

snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup circuit.r1cs pot12_final.ptau circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey circuit_0001.zkey verification_key.json

snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json

snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol
snarkjs zkey export soliditycalldata public.json proof.json

