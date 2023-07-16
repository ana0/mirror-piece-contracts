const MirrorPiece = artifacts.require('MirrorPiece');

module.exports = function (deployer) {
  deployer.deploy(MirrorPiece, 'Mirrors', 'MIRROR', 1000)
    .then(async (nft) => {
      await nft.setBaseURI('https://localhost:8080/api/mirrors');
      await nft.setController('0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b')
      //await nft.setContractURI('https://gateway.pinata.cloud/ipfs/QmSWm14gsoEExihXfkbQ55VwCc9VY3c71LeuTmNAr1v6jF/metadata.json')
    });
};
