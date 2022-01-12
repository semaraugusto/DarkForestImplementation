# mkdir -p tmp
# echo $# arguments 
# if [ $# -ne 2 ]; then 
#     echo "Usage ./make_transaction.sh 36 6"
#     echo "36 is x coordinate and 6 is y coordinate"
# fi

# x=$1;
# y=$2;

# echo "{\"x\": ${x}, \"y\": $y, \"r\": 65,\"s\": 32}" > ./tmp/user_input.json
# cat ./tmp/user_input.json

cd move_js;
node generate_witness.js move.wasm ../input_move_suc.json ../witness_move.wtns

cd ../
# snarkjs zkey export verificationkey move.zkey move_verification_key.json

snarkjs groth16 prove final.zkey witness_move.wtns proof_move.json public_move.json && snarkjs groth16 verify verification_key.json public_move.json proof_move.json && echo "$(snarkjs zkey export soliditycalldata public_move.json proof_move.json)" &> ./tmp/calldata_move && cat ./tmp/calldata_move
