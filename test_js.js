const express= require('express')
const Web3 = require('web3');
const contract = require('truffle-contract');
const artifacts = require('./build/contracts/GameState.json');

const snarkjs = require("snarkjs");
const fs = require("fs");

const wc = require('/home/semar/Projects/SemarDarkForest/circuit_js/witness_calculator.js')
const wasm = '/home/semar/Projects/SemarDarkForest/circuit_js/circuit.wasm'
const zkey = '/home/semar/Projects/SemarDarkForest/circuit_0001.zkey'
// const INPUTS_FILE = '/tmp/inputs'
const WITNESS_FILE = './tmp/witness.wtns'
const prompt = require('prompt-sync')({sigint: true});
const ffjavascript = require('ffjavascript')
const vk_verifier = JSON.parse(fs.readFileSync("verification_key.json"))
const unstringifyBigInts = ffjavascript.utils.unstringifyBigInts

const generateWitness = async (inputs) => {
    const buffer = fs.readFileSync(wasm);
    console.log("Got wasm file")
    const witnessCalculator = await wc(buffer)
    console.log("Got witness calculator")
    console.log(inputs)
    const buff = await witnessCalculator.calculateWTNSBin(inputs, 0);
    fs.writeFileSync(WITNESS_FILE, buff)
    return buff
}

const main = async () => {
    if (typeof web3 !== 'undefined') {
        var web3 = new Web3(web3.currentProvider)
      } else {
        var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:9545/'))
    }
    console.log("got web3")
    const GameState = contract(artifacts)
    console.log("got contract")
    GameState.setProvider(web3.currentProvider)
    console.log("seted provided")
    const accounts = await web3.eth.getAccounts();
    console.log("got accounts", accounts)
    const instance = await GameState.deployed();
    // console.log("got instance", instance)
    console.log("Got instance.")
    // const value = await instance.getMinSpawnDistance()
    let min_val = 32
    let max_val = 65
    console.log(min_val)
    console.log(max_val)
    // let x_val = prompt('input x coordinate');
    // let y_val = prompt('input y coordinate');
    let x_val = 44
    let y_val = 4

    // console.log(coords);
    // coords = coords.split(',')
    // let x_val = coords[0]
    // let y_val = coords[1]
    // console.log(x_val)
    // console.log(y_val)
    const inputSignals = { x: parseInt(x_val), y: parseInt(y_val), r: max_val, s: min_val } // replace with your signals
    console.log(inputSignals)
    const witness = await generateWitness(inputSignals)

    const {proof, publicSignals} = await snarkjs.groth16.prove(zkey, WITNESS_FILE);
    console.log(proof)
    console.log(publicSignals)
    const res = await snarkjs.groth16.verify(vk_verifier, publicSignals, proof);
    console.log(res)

    const calldata = await snarkjs.groth16.exportSolidityCallData(proof, publicSignals);
    /* const calldataSplit = calldata.split(',')
    let a = eval(calldataSplit.slice(0,2).join())
    let b = eval(calldataSplit.slice(2,6).join())
    let c = eval(calldataSplit.slice(6,8).join())
    let input = eval(calldataSplit.slice(8,9).join()) */
    // // const publicSignalsFormatted = JSON.parse(values[1]).map(x => BigInt(x).toString())
    //
    // const a = unstringifyBigInts(["0x21848993540432783293076759020334189109353184683595366157018127027057679644342", "0x20814371396318053752227218553012925270918735914498104982998568662401127951463"]);
    //
    // const b = unstringifyBigInts([
    //     ["0x20171067745304439398601868859732366797230782848033779680180716040867584222372", "0x9234266203405761094380361971955968657672623367572906714493946328178870912770"],
    //     ["0x19523807225348491003831238285694199677760121732069156942696153152115258527789", "0x6944199694294862207885472026469063098180822874220391751461804580071293349261"]
    // ]);
    //
    // const c = unstringifyBigInts(["0x18950923062637807618407644326834191397431696354039965505507299474871529159474", "0x18439352056930728826092990011864618071451880896289812370060772255723467759469"]);
    // const input = unstringifyBigInts(["0x14203648937718451807652769669274875988938340600926764176091915238749421404972"]);
    // const proofFormatted = calldataSplit[0]
    // const publicSignalsFormatted = JSON.parse(values[1]).map(x => BigInt(x).toString())
    //
    // console.log(result)
    // console.log(result.length)
    console.log(calldata)
    // console.log(a)
    // console.log(calldata.split(','))
    // a = ["0x264240e37d059c3a1df94b5c256a6a75f862fe5094d348e3b0320d059671517a", "0x02d96725d7a7ae412ad0a0e3bb2355cf6c43e9bbb11b4ee6aa83f246ba07b33d"]
    // b = [["0x18f0d95e315e6d0b38004815030ca10bdcfbf7f3debb46ca1872d864b1c39bcb", "0x14019c709d82800efb472beaccd95845ddc32b2b780d1a30737bbeeb06e4051b"],["0x02fe056b07b3b8009ee95c3c675730b02aacc46495093f7f7d3ce6dcf430f820", "0x26a8fb4524e50187bb832ce06553e1a9d3fa2dc7ceddf7c03751da4e7bdf7131"]]
    // c = ["0x1308381570f60df704e9a3e125c09c0b0202026a5d5dbd341e49753cd7838b4c", "0x27206e2ec5f7981819cc956e47c6c32b86fb39a53ba355fe1bac79a99993315e"]
    // input = ["0x0edf1e75af93136756becb1898ec53f49c2c495a1e72802e254f55ba9e14af0a"]

    const calldataSplit = calldata.split(",");
    let a = eval(calldataSplit.slice(0, 2).join());
    let b = eval(calldataSplit.slice(2, 6).join());
    let c = eval(calldataSplit.slice(6, 8).join());
    let input = eval(calldataSplit.slice(8, 12).join());
    /* a.map(unstringifyBigInts)
    b.map(unstringifyBigInts)
    c.map(unstringifyBigInts)
    input.map(unstringifyBigInts) */
    console.log("HEY")
    console.log(calldataSplit)
    console.log(a)
    console.log(b)
    console.log(c)
    console.log(input)

    // const test = await GameState.deployed().spawn(a, b, c, input)
    let result = await instance.spawn.call(a, b,c, input)
    console.log(result)
    /* instance.spawn(a, b, c, input).then(async (result) => {
        res = await result;
        console.log(res)
        console.log('hey');
        console.log(result);
    }.catch{error}; */
  // result object contains import information about the transaction
      /* console.log("HEYYYYYYYYYYYYY")
      console.log("Value was set to", result.logs[0].args.val);
      console.log("HEYYYYYYYYYYYYY")
    }); */
    // const test = await instance.spawn(calldata, {from: accounts[0]})

}

main().then(() => {
    process.exit(0);
});


// snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json && snarkjs groth16 verify verification_key.json public.json proof.json

// readline.question(`input coords: `, async coords => {
//     console.log(coords);
//     coords = coords.split(',')
//     let x_val = coords[0]
//     let y_val = coords[1]
//     console.log(x_val)
//     console.log(y_val)
//     var files = fs.readdirSync('./');
//     // console.log(files)
//     const inputSignals = { x: parseInt(x_val), y: parseInt(y_val), r: 64, s: 32 } // replace with your signals
//     const witness = await generateWitness(inputSignals)
//     // const {proof, publicSignals} = zkSnark.genProof(vk_proof, WITNESS_FILE);
//     // const { proof, publicSignals } = await snarkjs.groth16.fullProve({x: 1, y: 1, r: 8}, wasm, "circuit_final.zkey");
//     // console.log("witness; ")
//     // console.log(witness)
//     const {proof, publicSignals} = await snarkjs.groth16.prove(zkey, WITNESS_FILE);
//     // console.log(proof)
//     console.log(publicSignals)
//     // console.log(nproof)
//     // console.log(publicSignals)
//     const result = await snarkjs.groth16.exportSolidityCallData(proof, publicSignals);
//     console.log(result)
//
//     readline.close()
//     process.exit(0);
// })
