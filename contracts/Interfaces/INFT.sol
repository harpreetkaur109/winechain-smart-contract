//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "../libraries/structLib.sol";

interface INFT {
    
    function bulkMint(Struct.NFTData calldata NFT) external;
    function changeDeadline(uint256 tokenId, uint256 increament) external;
}