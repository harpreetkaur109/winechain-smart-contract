import { MarketPlace, MarketPlace__factory, Usd__factory, WineNFT, WineNFT__factory } from "../typechain-types"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { Usdc } from "../typechain-types/contracts/mock/USDC.sol";

describe("winechain", async () =>{
let NFT : WineNFT;
let Marketplace : MarketPlace;
let signers : SignerWithAddress[];
let owner : SignerWithAddress;
let USDC : Usdc;

beforeEach(async () => {
    signers = await ethers.getSigners();
    owner = signers[0];
    NFT = await new WineNFT__factory(owner).deploy();
    USDC= await new Usd__factory(owner).deploy();
    Marketplace = await new MarketPlace__factory(owner).deploy();
    await NFT.initialize(Marketplace.address);
    await Marketplace.initialize(NFT.address,owner.address,USDC.address);

});



})