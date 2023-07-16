const NFT = artifacts.require('NFT');

module.exports = function (deployer) {
  deployer.deploy(NFT, 'Mirror Piece', 'MIRROR', 1000)
    .then(async (nft) => {
      await nft.setBaseURI('https://localhost:8080/api/mirrors');
      //await nft.setContractURI('https://gateway.pinata.cloud/ipfs/QmSWm14gsoEExihXfkbQ55VwCc9VY3c71LeuTmNAr1v6jF/metadata.json')
    });
};
