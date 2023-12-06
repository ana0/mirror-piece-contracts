const MirrorPiece = artifacts.require('MirrorPiece');
const { ethers } = require("ethers");


module.exports = function (deployer) {
  deployer.deploy(MirrorPiece, 'Mirrors', 'MIR', 1000)
    .then(async (nft) => {
      await nft.setBaseURI('https://isthisa.computer/api/mirrors/');
      await nft.setController('0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b')
    
      await nft.setMintCode(ethers.solidityPackedKeccak256(["string"], ["test1"]));
      await nft.setMintCode(ethers.solidityPackedKeccak256(["string"], ["test2"]));
    });
};
