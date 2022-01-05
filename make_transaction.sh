mkdir -p tmp
echo $# arguments 
if [ $# -ne 2 ]; then 
    echo "Usage ./make_transaction.sh 36 6"
    echo "36 is x coordinate and 6 is y coordinate"
fi

x=$1;
y=$2;

echo "{\"x\": ${x}, \"y\": $y, \"r\": 65,\"s\": 32}" > ./tmp/user_input.json
cat ./tmp/user_input.json

cd circuit_js;
node generate_witness.js circuit.wasm ../tmp/user_input.json ../witness.wtns

cd ../
# snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json
# snarkjs groth16 prove circuit_0001.zkey circuit_js/witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json

snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json
# snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol
echo "$(snarkjs zkey export soliditycalldata public.json proof.json)" > ./tmp/calldata

cat ./tmp/calldata
