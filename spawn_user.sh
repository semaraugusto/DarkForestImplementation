cd spawn_js;
node generate_witness.js spawn.wasm ../input_spawn_suc.json ../witness_spawn.wtns

cd ../

snarkjs groth16 prove spawn.zkey witness_spawn.wtns proof_spawn.json public_spawn.json
snarkjs groth16 verify spawn_verification_key.json public_spawn.json proof_spawn.json

echo "$(snarkjs zkey export soliditycalldata public_spawn.json proof_spawn.json)" &> ./tmp/calldata_spawn

cat ./tmp/calldata_spawn
