const Verifier = artifacts.require("Verifier");
const GameState = artifacts.require("GameState");

module.exports = function (deployer) {
  deployer.deploy(Verifier).then(async () => {
    let instance = await Verifier.deployed();
    let verifier_addr = instance.address;
    console.log(verifier_addr);
    return deployer.deploy(GameState, verifier_addr, 32, 64);
  });
};
