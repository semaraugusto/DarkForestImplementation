const snarkjs = require("snarkjs");
const fs = require("fs");

const wc = require('/home/semar/Projects/SolidityProjects/tmp/darkforest/circuit_js/witness_calculator.js')
const wasm = './circuit_js/circuit.wasm'
const zkey = './circuit_0001.zkey'
// const INPUTS_FILE = '/tmp/inputs'
const WITNESS_FILE = './tmp/witness.wtns'

const generateWitness = async (inputs) => {
    const buffer = fs.readFileSync(wasm);
    const witnessCalculator = await wc(buffer)
    console.log(inputs)
    const buff = await witnessCalculator.calculateWTNSBin(inputs, 0);
    fs.writeFileSync(WITNESS_FILE, buff)
    return buff
}
// snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json
const readline = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
})

readline.question(`input coords: `, async coords => {
    console.log(coords);
    coords = coords.split(',')
    let x_val = coords[0]
    let y_val = coords[1]
    console.log(x_val)
    console.log(y_val)
    var files = fs.readdirSync('./');
    // console.log(files)
    const inputSignals = { x: parseInt(x_val), y: parseInt(y_val), r: 64, s: 32 } // replace with your signals
    const witness = await generateWitness(inputSignals)
    // const {proof, publicSignals} = zkSnark.genProof(vk_proof, WITNESS_FILE);
    // const { proof, publicSignals } = await snarkjs.groth16.fullProve({x: 1, y: 1, r: 8}, wasm, "circuit_final.zkey");
    // console.log("witness; ")
    // console.log(witness)
    const {proof, publicSignals} = await snarkjs.groth16.prove(zkey, WITNESS_FILE);
    // console.log(proof)
    console.log(publicSignals)
    // console.log(nproof)
    // console.log(publicSignals)
    const result = await snarkjs.groth16.exportSolidityCallData(proof, publicSignals);
    console.log(result)

    readline.close()
    process.exit(0);
})



// const main = async () => {
//     var files = fs.readdirSync('./');
//     console.log(files)
//     const inputSignals = { x: 36, y: 6, r: 64, s: 32 } // replace with your signals
//     const witness = await generateWitness(inputSignals)
//     // const {proof, publicSignals} = zkSnark.genProof(vk_proof, WITNESS_FILE);
//     // const { proof, publicSignals } = await snarkjs.groth16.fullProve({x: 1, y: 1, r: 8}, wasm, "circuit_final.zkey");
//     console.log("witness; ")
//     console.log(witness)
//     const {proof, publicSignals} = await snarkjs.groth16.prove(zkey, WITNESS_FILE);
//     console.log(proof)
//     console.log(publicSignals)
//     // console.log(nproof)
//     // console.log(publicSignals)
//     const result = await snarkjs.groth16.exportSolidityCallData(proof, publicSignals);
//     console.log(result)
// }
//
// main().then(() => {
//     process.exit(0);
// });
