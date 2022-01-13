echo $# arguments 
mkdir -p ./tmp;
if [ $# -ne 4 ]; then 
    echo "Usage ./move_user.sh 36 6 44 4"
    echo "36 is x coordinate and 6 is y coordinate"
fi

x1=$1;
y1=$2;
x2=$3;
y2=$4;

echo "{\"x1\": $x1, \"y1\": $y1, \"x2\": $x2, \"y2\": $y2, \"distMove\": 16, \"distMax\": 128}" > ./tmp/user_input.json
cat ./tmp/user_input.json

cd move_js;
node generate_witness.js move.wasm ../tmp/user_input.json ../witness_move.wtns

cd ../
snarkjs groth16 prove move.zkey witness_move.wtns proof_move.json public_move.json
snarkjs groth16 verify move_verification_key.json public_move.json proof_move.json

echo "$(snarkjs zkey export soliditycalldata public_move.json proof_move.json)" &> ./tmp/calldata_move

cat ./tmp/calldata_move
