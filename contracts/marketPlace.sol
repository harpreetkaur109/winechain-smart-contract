//SPDX-License_Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./libraries/structLib.sol";
import "contracts/NFTContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract marketPlace is wineNFT {
    address NFTContract;
    address admin;
    uint256 planNumber;
    address usdt;
    struct NFTSell {
        address winery;
        uint256[] tokenIds;
        uint256 price;
    }
    struct planDetails {
        uint256 months;
        uint256 price;
    }
    mapping(uint256 => plans) internal plans;
    mapping(address => bool) internal operators;

    modifier onlyAdmin() {
        require(msg.sender == admin, "NA"); //Not Admin
        _;
    }

    function initialize(
        address _NFTContract,
        address _admin,
        address _usdt
    ) external {
        NFTContract = INFT(_NFTContract);
        admin = _admin;
        planNumber = 1;
        usdt = IERC20(_usdt);
    }

    function createNFT(Struct.NFTData calldata NFT) external onlyAdmin{
        NFTContract.bulkMint(NFT);
    }

    function buyNFT() external {}

    function createPlan(uint256 _months, uint256 _price) external onlyAdmin {
        plans[planNumber].months = _months;
        plans[planNumber].price = _price;
        planNumber++;
    }

    function buyStorage(uint256 tokenId, uint256 _planNumber) external {
        usdt.transferFrom(msg.sender, admin, plans[_planNumber].price);
        NFTContract.changeDeadline(tokenId, plans[_plannumber].months);
    }

    function renewStorage(uint256 tokenId, uint256 _planNumber)
        external
        onlyAdmin
    {
        NFTContract.changeDeadline(tokenId, plans[_plannumber].months);
    }
}
