const SpawnVerifier = artifacts.require("SpawnVerifier");
const MoveVerifier = artifacts.require("MoveVerifier");
const GameState = artifacts.require("GameState");
const Planet = artifacts.require("Planet");
const Types = artifacts.require("Types");

module.exports = function (deployer) {
    deployer.deploy(SpawnVerifier).then(async () => {
        let spawnVerifier = await SpawnVerifier.deployed();
        await deployer.deploy(MoveVerifier);
        let moveVerifier = await MoveVerifier.deployed()
        let spawn_verifier_addr = spawnVerifier.address;
        let move_verifier_addr = moveVerifier.address;
        console.log(spawn_verifier_addr);

        await deployer.deploy(Planet);
        await deployer.link(Planet, GameState) 
        await deployer.deploy(Types);
        await deployer.link(Types, GameState) 

        await deployer.deploy(GameState, spawn_verifier_addr, move_verifier_addr, 32, 64);
    });
};
