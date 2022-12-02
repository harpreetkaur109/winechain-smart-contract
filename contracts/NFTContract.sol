//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import "./Relayer/BasicMetaTransaction.sol";
import "./libraries/structLib.sol";
import "hardhat/console.sol";

contract wineNFT is ERC721URIStorageUpgradeable, BasicMetaTransaction {
    uint256 count;
    bool isInitialised;
    mapping(uint256 => Struct.NFTData) internal data;
    mapping (uint => uint256) internal deadline;
    mapping(address => bool) internal operators;
    event minted(uint256, uint256);
    modifier onlyOperator() {
        require(operators[msg.sender], "IC"); //Invalid caller
        _;
    }

    function initialize(address _marketPlace,address admin) external 
    {
        require(!isInitialised,"AI");//Already Initialised
        isInitialised = true;
        operators[_marketPlace] = true;
        operators[admin] = true;
        count = 1;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable) onlyOperator {
        console.log("hey");
        require(block.timestamp <= deadline[tokenId], "FN"); //Frozen NFT
        super._transfer(from, to, tokenId);
    }

    function changeReleaseDate(uint256 tokenId, uint256 _newDate)
        external
        onlyOperator
    {
        require(_exists(tokenId),"IT");
        // require(block.timestamp <= data[tokenId].releaseDate - 5 days,"TE");//Timeline Exceeded
        require(_newDate > data[tokenId].releaseDate, "ID"); //Invalid Date
        data[tokenId].releaseDate = _newDate;
        deadline[tokenId] = data[tokenId].releaseDate + 7890000;
    }

    function increaseDeadline(uint256 tokenId, uint256 increament)
        external
        onlyOperator
    {
        require(_exists(tokenId),"IT");
        deadline[tokenId] += increament;
    }

    function setDeadline(uint256 tokenId, uint256 time) external onlyOperator{
        require(_exists(tokenId),"IT");
        console.log("deadline 1",deadline[tokenId]);
        deadline[tokenId] = time;
        console.log("deadline 2",deadline[tokenId]);

    }

    function bulkMint(Struct.NFTData calldata NFT) external onlyOperator {
       
        uint256 start = count;
        for (uint256 i = count; i < count + NFT.amount; i++) {
            _mint(NFT.winery, i);
            _setTokenURI(i, NFT.URI);
            data[i] = NFT;
            deadline[i] = data[i].releaseDate + 7890000;
        }
        count = count + NFT.amount;
        emit minted(start, count - 1);
    }

    function checkDeadline(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId),"IT");
        return deadline[tokenId];
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
