//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

contract wineNFT is ERC721URIStorageUpgradeable {
    address marketPlace;
    uint256 count ;
     struct NFTData{
        address winery;
        uint256 releaseDate;
        uint amount;
        string URI;

    }
    mapping(address => uint256) internal frozenNft;
    event minted(uint256, uint256);
    event NftUnfrozen(address, uint256);

    function initialize(address _marketPlace) external initializer {
        marketPlace = _marketPlace;
        count =1;
    }


    function _transfer(address from, address to, uint256 tokenId) internal override(ERC721Upgradeable) {
            require(msg.sender == marketPlace,"IC");//Invalid caller

            super._transfer(from,to,tokenId);
    }

    function bulkMint(uint256 amount, address to, string memory _uri) internal  {
        uint start =  count;
        for(uint256 i=count;i<count + amount;i++){
            _mint(to,i);
            _setTokenURI(i, _uri);
        }
        count = count+ amount; 
        emit minted(start, count-1);

    }
    // function freezePartialNft(
    //     address _Nft,
    //     uint256 _amount,
    //     address _NftHolder
    // ) public {
    //     uint256 balance = balanceOf(_NftHolder);
    //     require(
    //         balance >= frozenNft[_NftHolder] + _amount,
    //         "Amount exceeds available balance"
    //     );
    //     frozenNft[_NftHolder] = frozenNft[_NftHolder] + (_amount);
    //     emit NftFrozen(_NftHolder, _amount);
    // }

    // function unfreezePartialTokens(address _Nft,uint256 _amount,address _NftHolder)
    //     public
    // {
    //     require(
    //         frozenNft[_NftHolder] >= _amount,
    //         "Amount should be less than or equal to frozen tokens"
    //     );
    //     frozenNft[_NftHolder] = frozenNft[_NftHolder] - (_amount);
    //     emit NftUnfrozen(_NftHolder, _amount);
    // }
}
