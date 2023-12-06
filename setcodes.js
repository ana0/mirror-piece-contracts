const csv = require("csv-parser");
const fs = require("fs");
require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const { ethers } = require("ethers");

const truffleContract = require('truffle-contract');
const nftArtifacts = require('./build/contracts/MirrorPiece.json');
const Web3 = require('web3');

const web3 = new Web3(new HDWalletProvider(
        process.env.MNEMONIC,
        `https://polygon-rpc.com/`
      ));

const Nft = truffleContract(nftArtifacts);

Nft.setProvider(web3.currentProvider);

let codes = []


const test = async () => {
  const accounts = await web3.eth.getAccounts();

  const nft = await Nft.at("0xedc1929675Ee144E51521D23515A06eF0184840e");

  console.log("trying to set")
  console.log(codes)

  for(let i=0; i < codes.length; i++) {
    //await nft.setMintCode(ethers.solidityPackedKeccak256(["string"], [codes[i]]), { from: accounts[0] });
    await web3.eth.sendTransaction({ to: codes[i], value: web3.utils.toWei("0.3", "ether"), from: accounts[0] })
    console.log("set ", codes[i]);
  }

  console.log('done');
  process.exit();
}

fs.createReadStream("./mirrorcodes.csv")
  .pipe(csv())
  .on("data", async (row) => {
    console.log(row);
    codes.push(row.address);
    return
  })
  .on("end", () => {
    console.log("CSV file successfully processed");
    test();
  });
