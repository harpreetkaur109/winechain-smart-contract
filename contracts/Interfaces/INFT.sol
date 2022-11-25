//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "../libraries/structLib.sol";

interface INFT {
    function bulkMint(Struct.NFTData calldata NFT) external;

    function changeDeadline(uint256 tokenId, uint256 increament) external;

    function changeReleaseDate(uint256 tokenId, uint256 _newDate) external;

    function checkDeadline(uint256 tokenId) external view returns (uint256);

    function setDeadline(uint256 tokenId, uint256 time) external;
}
