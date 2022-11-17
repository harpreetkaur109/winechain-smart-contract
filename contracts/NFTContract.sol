//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "./libraries/structLib.sol";

contract wineNFT is ERC721URIStorageUpgradeable {
    address marketPlace;
    uint256 count;

    mapping(uint256 => Struct.NFTData) internal data;
    event minted(uint256, uint256);
    event NftUnfrozen(address, uint256);

    function initialize(address _marketPlace) external  {
        marketPlace = _marketPlace;
        count = 1;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable) {
        require(msg.sender == marketPlace, "IC"); //Invalid caller
        require(block.timestamp <= data[tokenId].deadline,"FN");//Frozen NFT 
        super._transfer(from, to, tokenId);
    }

    function changeDeadline(uint256 tokenId, uint256 increament) external {
        require(_exists(tokenId));
        data[tokenId].deadline += increament;
    }

    function bulkMint(Struct.NFTData calldata NFT) external {
        uint256 start = count;
        for (uint256 i = count; i < count + NFT.amount; i++) {
            _mint(NFT.winery, i);
            _setTokenURI(i, NFT.URI);
            data[i] = NFT;
            data[i].deadline = data[i].releaseDate + 7890000;
        }
        count = count + NFT.amount;
        emit minted(start, count - 1);
    }

    function checkDeadline(uint256 tokenId) external view returns(uint256){
        require(_exists(tokenId));
        return data[tokenId].deadline;
    }

   
    

   
}
