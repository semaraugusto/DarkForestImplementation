mkdir -p ./tmp;

cd move_js;
node generate_witness.js move.wasm ../input_move_suc.json ../witness_move.wtns

cd ../
snarkjs groth16 prove move.zkey witness_move.wtns proof_move.json public_move.json
snarkjs groth16 verify move_verification_key.json public_move.json proof_move.json

echo "$(snarkjs zkey export soliditycalldata public_move.json proof_move.json)" &> ./tmp/calldata_move

cat ./tmp/calldata_move
