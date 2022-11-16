//SPDX-License_Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./libraries/structLib.sol";
import "./Interfaces/INFT.sol";

contract marketPlace {
address NFTContract;
address admin;
   function initialize(address NFT,address _admin)external {
        NFTContract =NFT;
        admin = _admin;
   }


   function createNFT(Struct.NFTData calldata NFT) external {

    INFT(NFTContract).bulkMint(NFT);

   }

   function buyNFT()
}