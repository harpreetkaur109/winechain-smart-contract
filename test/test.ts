import { MarketPlace, MarketPlace__factory, Usdc__factory, WineNFT, WineNFT__factory } from "../typechain-types"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { Usdc } from "../typechain-types/contracts/mock/USDC.sol";
import { expect } from "chai";
import SellerVoucher from "./utilities/SellerVoucher";

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
    await NFT.initialize(Marketplace.address,owner.address);
    await Marketplace.initialize(NFT.address,owner.address,USDC.address);
    await USDC.connect(owner).mint(signers[1].address,1000);
    await USDC.connect(owner).mint(signers[2].address,1000);
    await USDC.connect(owner).mint(signers[3].address,1000);
})

it("ERROR: already initialized ", async () =>{
  await expect(NFT.initialize(Marketplace.address,owner.address)).to.be.revertedWith("AI");
})

it("bulk mint  ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
})

it("ERROR: invalid caller for bulk mint", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await expect (NFT.connect(signers[3]).bulkMint(nft)).to.be.revertedWith("IC");
})

it("multiple bulk mint  ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }

  let nft2 = {
    winery:signers[1].address,
    releaseDate: 1777217037,
    amount:10,
    royaltyAmount:10,
    URI:"NFT2"
  }
await NFT.connect(owner).bulkMint(nft);
await NFT.connect(owner).bulkMint(nft2);
expect(await NFT.balanceOf(signers[1].address)).to.be.eq(14);
})

it("increase deadline ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await NFT.increaseDeadline(4,4567);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037+4567);
expect (await NFT.connect(owner).checkDeadline(1)).to.be.eq(1685107037);
})

it("increase deadline ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
await expect(NFT.connect(owner).checkDeadline(5)).to.be.revertedWith("IT");
})



it("ERROR :increase deadline,, invalid token ID ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await expect (NFT.increaseDeadline(5,4567)).to.be.revertedWith("IT");
})

it("update release date ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await NFT.connect(owner).changeReleaseDate(4,1678217037);
})

it("ERROR:non operator caller for update release date ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await expect(NFT.connect(signers[1]).changeReleaseDate(4,1678217037)).to.be.revertedWith("IC");
})

it("ERROR: updated date invalid ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await expect(NFT.changeReleaseDate(4,1668217037)).to.be.revertedWith("ID");
})

it("ERROR: update release date, invalid tokenID ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await expect(NFT.changeReleaseDate(5,1668217037)).to.be.revertedWith("IT");
})

it("set deadline ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await NFT.connect(owner).setDeadline(4,1778217037);
})

it("set deadline ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await expect(NFT.connect(signers[1]).setDeadline(4,1778217037)).to.be.revertedWith("IC");
})
it("ERROR : set deadline, invalid token ID ", async () => {
   
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
await NFT.connect(owner).bulkMint(nft);
expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
await expect(NFT.setDeadline(6,1778217037)).to.be.revertedWith("IT");

})
// check for deadline number
// it.only("ERROR : set deadline, invalid token ID ", async () => {
   
//   let nft = {
//     winery:signers[1].address,
//     releaseDate: 1677217037,
//     amount:4,
//     royaltyAmount:10,
//     URI:"NFT1"
//   }
// await NFT.connect(owner).bulkMint(nft);
// expect (await NFT.connect(owner).checkDeadline(4)).to.be.eq(1685107037);
// await NFT.setDeadline(4,1);
// console.log("deadline",await NFT.connect(owner).checkDeadline(4));


// })

it("initialize ", async () =>{
  await Marketplace.initialize(NFT.address,owner.address,USDC.address);
})

it("ERROR:zero address passed in initialize ", async () =>{
  await expect(Marketplace.initialize("0x0000000000000000000000000000000000000000",owner.address,USDC.address)).to.be.revertedWith("ZA");
  await expect(Marketplace.initialize(NFT.address,"0x0000000000000000000000000000000000000000",USDC.address)).to.be.revertedWith("ZA");
  await expect(Marketplace.initialize(NFT.address,owner.address,"0x0000000000000000000000000000000000000000")).to.be.revertedWith("ZA");
})

it ("create NFT", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);

 expect(await NFT.balanceOf(signers[1].address)).to.be.eq(4);

})

it("ERROR: create NFT caller is not owner", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await expect (Marketplace.connect(signers[1]).createNFT(nft)).to.be.revertedWith("NA");
})

it("ERROR : create NFT, zero address", async () =>{
  let nft = {
    winery:"0x0000000000000000000000000000000000000000",
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await expect (Marketplace.connect(owner).createNFT(nft)).to.be.revertedWith("ZA");
})

it("ERROR : create NFT, invalid release date", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 16772170,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await  expect(Marketplace.connect(owner).createNFT(nft)).to.be.revertedWith("ID");

})
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
it.only("Buy NFT", async () =>{

  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);
  console.log("ownernfts",await NFT.balanceOf(signers[1].address))
  await NFT.connect(signers[1]).setApprovalForAll(Marketplace.address,true);

   await USDC.connect(signers[2]).approve(
        Marketplace.address,
        1000000
      );
      await USDC.connect(signers[3]).approve(
        Marketplace.address,
        1000000
      );

      // creating vouchers
      const seller = new SellerVoucher({
        _contract: Marketplace,
        _signer : signers[1],
      });

    console.log("test cases",signers[1].address);
      const sellerVoucher = await seller.createVoucher(
        signers[1].address,
        signers[1].address,
        1,
        100
      )
     
    console.log("sellervoucher",sellerVoucher);
    console.log("balance",await NFT.balanceOf(signers[1].address));
    await Marketplace.connect(signers[2]).buyNFT(sellerVoucher,{gasLimit:3000000});
    console.log("balance",await NFT.balanceOf(signers[1].address));

    expect(await NFT.ownerOf(1)).to.be.eq(signers[2].address);
    // await Marketplace.connect(signers[3]).buyNFT(sellerVoucher,1,{gasLimit:3000000});

//     await Marketplace.connect(signers[3]).buyNFT(sellerVoucher,1);
//     expect(await NFT.ownerOf(2)).to.be.eq(signers[3].address);
})

it("ERROR:Winery address zero for Buy NFT", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);
  await NFT.connect(signers[1]).setApprovalForAll(Marketplace.address,true);

await USDC.connect(signers[2]).approve(
        Marketplace.address,
        1000000
      );
      await USDC.connect(signers[3]).approve(
        Marketplace.address,
        1000000
      );   
   
     //creating vouchers
     const seller = new SellerVoucher({
      _contract: Marketplace,
      _signer : signers[1],
    });

    const sellerVoucher = await seller.createVoucher(
      "0x0000000000000000000000000000000000000000",
      signers[1].address,
      [1,2,3],
      100,
      2,
    )
    await expect (Marketplace.connect(signers[2]).buyNFT(sellerVoucher,1)).to.be.revertedWith("ZA");
})

it("ERROR:Seller address zero for Buy NFT", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);
  await NFT.connect(signers[1]).setApprovalForAll(Marketplace.address,true);

await USDC.connect(signers[2]).approve(
        Marketplace.address,
        1000000
      );
      await USDC.connect(signers[3]).approve(
        Marketplace.address,
        1000000
      );
    
        //creating vouchers
        const seller = new SellerVoucher({
          _contract: Marketplace,
          _signer : signers[1],
        });
  
        const sellerVoucher = await seller.createVoucher(
          signers[1].address,
          "0x0000000000000000000000000000000000000000",
          [1,2,3],
          100,
          2,
        )
      
    await expect(Marketplace.connect(signers[2]).buyNFT(sellerVoucher,1)).to.be.revertedWith("ZA");
  
})


// it.only("secondary Buy NFT", async () =>{
//   let nft = {
//     winery:signers[1].address,
//     releaseDate: 1677217037,
//     amount:4,
//     royaltyAmount:10,
//     URI:"NFT1"
//   }
//   await Marketplace.connect(owner).createNFT(nft);
//   await NFT.connect(signers[1]).setApprovalForAll(Marketplace.address,true);

// await USDC.connect(signers[2]).approve(
//         Marketplace.address,
//         1000000
//       );
//       await USDC.connect(signers[3]).approve(
//         Marketplace.address,
//         1000000
//       );
//       // await USDT.connect(signers[1]).approve(
//       //   marketplace.address,
//       //   expandTo18Decimals(60)
//       // );
      
//       let sell ={
//         winery : signers[1].address,
//         seller : signers[1].address,
//         tokenId : [1,2,3],
//         price : 100,
//         amount: 2,
//     }

//     await Marketplace.connect(signers[2]).buyNFT(sell,1);
//     expect(await NFT.ownerOf(1)).to.be.eq(signers[2].address);
//     await Marketplace.connect(signers[3]).buyNFT(sell,1);
//     expect(await NFT.ownerOf(2)).to.be.eq(signers[3].address);

//     await NFT.connect(signers[2]).setApprovalForAll(Marketplace.address,true);

//     let sell2 ={
//       winery : signers[1].address,
//       seller : signers[2].address,
//       tokenId : [1,2,3],
//       price : 150,
//       amount: 1,
//   }

//     let plan = {
//     months:10,
//     price:50 
//   }
//   await Marketplace.connect(owner).createPlan(plan);
//   await USDC.connect(signers[2]).approve(
//     Marketplace.address,
//     1000000000000000
//   );
//   await Marketplace.connect(signers[2]).buyStorage(1,1);

//     await Marketplace.connect(signers[3]).buyNFT(sell2,1);


// })




// it.only("Secondary NFT buy", async () =>{
//   //primary buy
//   let nft = {
//     winery:signers[1].address,
//     releaseDate: 1677217037,
//     amount:4,
//     royaltyAmount:10,
//     URI:"NFT1"
//   }
//   await Marketplace.connect(owner).createNFT(nft);
//   await NFT.connect(signers[1]).setApprovalForAll(Marketplace.address,true);

// await USDC.connect(signers[2]).approve(
//         Marketplace.address,
//         1000000
//       );
//       await USDC.connect(signers[3]).approve(
//         Marketplace.address,
//         1000000
//       );
//       // await USDT.connect(signers[1]).approve(
//       //   marketplace.address,
//       //   expandTo18Decimals(60)
//       // );
      
//       let sell ={
//         winery : signers[1].address,
//         seller : signers[1].address,
//         tokenId : [1,2,3],
//         price : 100,
//         amount: 2,
//     }

//     await Marketplace.connect(signers[2]).buyNFT(sell,1);
//     expect(await NFT.ownerOf(1)).to.be.eq(signers[2].address);
//     await Marketplace.connect(signers[3]).buyNFT(sell,1);
//     expect(await NFT.ownerOf(2)).to.be.eq(signers[3].address);
//     // secondary buy
//     await NFT.connect(signers[2]).setApprovalForAll(Marketplace.address,true);
//     await USDC.connect(signers[3]).approve(
//       Marketplace.address,
//       1000000000000000
//     );
//     await USDC.connect(signers[2]).approve(
//       Marketplace.address,
//       1000000000000000
//     );
//     let sell2 ={
//       winery : signers[1].address,
//       seller : signers[2].address,
//       tokenId : [1,2,3],
//       price : 100,
//       amount: 1,
//   }

//   let plan = {
//     months:1050,
//     price:50 
//   }
//   await Marketplace.connect(owner).createPlan(plan);
//   await USDC.connect(signers[2]).approve(
//     Marketplace.address,
//     1000000000000000
//   );
//   await Marketplace.connect(signers[2]).buyStorage(1,1);


//   await Marketplace.connect(signers[3]).buyNFT(sell2,1);
//   // console.log(await USDC.balanceOf(owner.address));
//   // console.log(await USDC.balanceOf(signers[2].address));
//   // expect(await NFT.ownerOf(1)).to.be.eq(signers[3].address);
//   // expect(await NFT.ownerOf(1)).to.be.eq(signers[3].address);
// })


it("ERROR: NFT already sold", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.createNFT(nft);
  await NFT.connect(signers[1]).setApprovalForAll(Marketplace.address,true);

await USDC.connect(signers[2]).approve(
        Marketplace.address,
        1000000
      );
      await USDC.connect(signers[3]).approve(
        Marketplace.address,
        1000000
      );
      // await USDT.connect(signers[1]).approve(
      //   marketplace.address,
      //   expandTo18Decimals(60)
      // );
    

     //creating vouchers
     const seller = new SellerVoucher({
      _contract: Marketplace,
      _signer : signers[1],
    });

    const sellerVoucher = await seller.createVoucher(
      signers[1].address,
      signers[1].address,
      [1,2,3],
      100,
      2,
    )


    await Marketplace.connect(signers[2]).buyNFT(sellerVoucher,1);
    expect(await NFT.ownerOf(1)).to.be.eq(signers[2].address);
    await Marketplace.connect(signers[3]).buyNFT(sellerVoucher,1);
    expect(await NFT.ownerOf(2)).to.be.eq(signers[3].address);
    await expect (Marketplace.connect(signers[3]).buyNFT(sellerVoucher,1)).to.be.revertedWith("AS");
})


it("create plan  ", async () => {
    
  let plan = {
    months:6,
    price:100 
  }
    await Marketplace.connect(owner).createPlan(plan);
  })

  it("ERROR:non admin caller for create plan  ", async () => {
    
    let plan = {
      months:6,
      price:100 
    }
      await expect(Marketplace.connect(signers[1]).createPlan(plan)).to.be.revertedWith("NA");
    })
 
  it("ERROR :create plan,invalid price", async () => {
    
    let plan = {
      months:9,
      price:0 
    }
      await expect (Marketplace.connect(owner).createPlan(plan)).to.be.rejectedWith("IV");
  })  
  it("ERROR :create plan,invalid month", async () => {
    
    let plan = {
      months:0,
      price:100 
    }
      await expect (Marketplace.connect(owner).createPlan(plan)).to.be.rejectedWith("IV");
  })  

it("change release date ", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);
  await Marketplace.connect(owner).changereleaseDate(1,1678217037);
  await Marketplace.connect(owner).changereleaseDate(2,1678917037);

})

it("ERROR: non admin caller for change release date ", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);
  await expect(Marketplace.connect(signers[1]).changereleaseDate(1,1678217037)).to.be.revertedWith("NA");

})

it("ERROR: invalid release date", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);
  await expect (Marketplace.connect(owner).changereleaseDate(1,167821703)).to.be.revertedWith("ID");

})

it("increase deadine ", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);
  await Marketplace.connect(owner).changereleaseDate(1,1678217037);
  await NFT.connect(owner).increaseDeadline(2,500);
})

it("ERROR:non operator caller for increase deadine ", async () =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);
  await Marketplace.connect(owner).changereleaseDate(1,1678217037);
  await expect(NFT.connect(signers[1]).increaseDeadline(2,500)).to.be.revertedWith("IC");
})



it ("renew storage ", async() =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);

  let plan = {
    months:6,
    price:100 
  }
    await Marketplace.connect(owner).createPlan(plan);
    await Marketplace.connect(owner).renewStorage(1,1);
})


it("ERROR:non admin caller for renew storage ", async() =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);

  let plan = {
    months:6,
    price:100 
  }
    await Marketplace.connect(owner).createPlan(plan);
    await expect (Marketplace.connect(signers[1]).renewStorage(1,1)).to.be.revertedWith("NA");
})
  
it("buy storage ", async() =>{
  let nft = {
    winery:signers[1].address,
    releaseDate: 1677217037,
    amount:4,
    royaltyAmount:10,
    URI:"NFT1"
  }
  await Marketplace.connect(owner).createNFT(nft);

  let plan = {
    months:12,
    price:50
  }
    await Marketplace.connect(owner).createPlan(plan);
    expect(await NFT.ownerOf(1)).to.be.eq(signers[1].address);

    await USDC.connect(owner).mint(signers[4].address,1000000000000000);

    await USDC.connect(signers[4]).approve(
      Marketplace.address,
      1000000000000000
    );
    await Marketplace.connect(signers[4]).buyStorage(1,1);
})

});