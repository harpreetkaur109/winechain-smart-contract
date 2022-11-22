import { MarketPlace, MarketPlace__factory, Usdc__factory, Usd__factory, WineNFT, WineNFT__factory } from "../typechain-types"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { Usdc } from "../typechain-types/contracts/mock/USDC.sol";
import { expandTo15Decimals, expandTo16Decimals, expandTo17Decimals, expandTo18Decimals } from "./utilities/utilities";
import { Struct } from "../typechain-types/contracts/MarketPlace";


describe("winechain", async () =>{
let NFT : WineNFT;
let Marketplace : MarketPlace;
let signers : SignerWithAddress[];
let owner : SignerWithAddress;
let USDC : Usdc;

beforeEach(async () => {
    signers = await ethers.getSigners();
    owner = signers[0];
    USDC= await new Usdc__factory(owner).deploy();
    NFT = await new WineNFT__factory(owner).deploy();
    Marketplace = await new MarketPlace__factory(owner).deploy();
    await NFT.initialize(Marketplace.address);
    await Marketplace.initialize(NFT.address,owner.address,USDC.address);

});
it("create NFT ", async () => {
    
    let a = {
        winery : owner.address,
        releaseDate : 1,
        amount : 1,
        deadline : 1,
        URI : "23"
    };
    await Marketplace.connect(owner).createNFT(a);
  });




})