//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import "./Relayer/BasicMetaTransaction.sol";
import "./libraries/structLib.sol";

contract wineNFT is
    ERC721URIStorageUpgradeable,
    BasicMetaTransaction
{
    uint256 count;

    mapping(uint256 => Struct.NFTData) internal data;
    mapping(address => bool) internal operators;
    event minted(uint256, uint256);
    modifier onlyOperator() {
        require(operators[msg.sender], "IC"); //Invalid caller
        _;
    }

    function initialize(address _marketPlace) external {
        operators[_marketPlace] = true;
        count = 1;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable) onlyOperator {
        require(block.timestamp <= data[tokenId].deadline, "FN"); //Frozen NFT
        super._transfer(from, to, tokenId);
    }

    function changeReleaseDate(uint256 tokenId, uint256 _newDate)
        external
        onlyOperator
    {
        require(_exists(tokenId));
        // require(block.timestamp <= data[tokenId].releaseDate - 5 days,"TE");//Timeline Exceeded
        require(_newDate > data[tokenId].releaseDate, "ID"); //Invalid Date
        data[tokenId].releaseDate = _newDate;
        data[tokenId].deadline = data[tokenId].releaseDate + 7890000;
    }

    function changeDeadline(uint256 tokenId, uint256 increament)
        external
        onlyOperator
    {
        require(_exists(tokenId));
        data[tokenId].deadline += increament;
    }

    function bulkMint(Struct.NFTData calldata NFT) external onlyOperator {
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

    function checkDeadline(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId));
        return data[tokenId].deadline;
    }

    // function supportsInterface(bytes4 interfaceId)
    //     public
    //     view
    //     override(ERC721Upgradeable, ERC2981Upgradeable)
    //     returns (bool)
    // {
    //     return super.supportsInterface(interfaceId);
    // }

    function _msgSender()
        internal
        view
        override(ContextUpgradeable, BasicMetaTransaction)
        returns (address sender)
    {
        return super._msgSender();
    }
}
