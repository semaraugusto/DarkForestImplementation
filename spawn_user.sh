mkdir -p tmp
# echo $# arguments 
# if [ $# -ne 2 ]; then 
#     echo "Usage ./make_transaction.sh 36 6"
#     echo "36 is x coordinate and 6 is y coordinate"
# fi

# x=$1;
# y=$2;

# echo "{\"x\": ${x}, \"y\": $y, \"r\": 65,\"s\": 32}" > ./tmp/user_input.json
# cat ./tmp/user_input.json

cd spawn_js;
node generate_witness.js spawn.wasm ../input_spawn_suc.json ../tmp/witness_spawn.wtns

cd ../
# snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json
# snarkjs groth16 prove circuit_0001.zkey circuit_js/witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json

snarkjs groth16 prove spawn.zkey ./tmp/witness_spawn.wtns proof_spawn.json public_spawn.json && snarkjs groth16 verify spawn_verification_key.json public_spawn.json proof_spawn.json
# snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol
echo "$(snarkjs zkey export soliditycalldata public_spawn.json proof_spawn.json)" &> ./tmp/calldata_spawn

cat ./tmp/calldata_spawn
