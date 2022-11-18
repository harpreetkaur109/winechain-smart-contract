//SPDX-License_Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./libraries/structLib.sol";
import "./Interfaces/INFT.sol";
import "./Relayer/BasicMetaTransaction.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

contract marketPlace is BasicMetaTransaction {
    address NFTContract;
    address admin;
    uint256 planNumber;
    IERC20 public usdc;

    mapping(uint256 => Struct.planDetails) internal plans;
    mapping(address => bool) internal operators;
    mapping(address => uint256) internal leftAmount;
    mapping(address => bool) internal allSold;
    mapping(address => uint256) internal currentIndex;

    modifier onlyAdmin() {
        require(msg.sender == admin, "NA"); //Not Admin
        _;
    }

    function initialize(
        address _NFTContract,
        address _admin,
        address _usdc
    ) external {
        NFTContract = _NFTContract;
        admin = _admin;
        planNumber = 1;
        usdc = IERC20(_usdc);
    }

    function createNFT(Struct.NFTData calldata NFT) external onlyAdmin {
        INFT(NFTContract).bulkMint(NFT);
    }

    function buyNFT(Struct.NFTSell calldata sell, uint256 amount) external {
        setAmount(sell, amount);
        usdc.transferFrom(msg.sender, admin, amount * sell.price);
        for (uint256 i = currentIndex[sell.winery]; i < currentIndex[sell.winery] + amount; i++) {
            IERC721Upgradeable(NFTContract).transferFrom(
                sell.winery,
                msg.sender,
                sell.tokenIds[i]
            );
        }
        currentIndex[sell.winery] += amount;
    }

    function createPlan(Struct.planDetails calldata _planDetails)
        external
        onlyAdmin
    {
        plans[planNumber].months = _planDetails.months;
        plans[planNumber].price = _planDetails.price;
        planNumber++;
    }

    function changereleaseDate(uint256 tokenId, uint256 _newDate)
        external
        onlyAdmin
    {
        INFT(NFTContract).changeReleaseDate(tokenId, _newDate);
    }

    function buyStorage(uint256 tokenId, uint256 _planNumber) external {
        usdc.transferFrom(msg.sender, admin, plans[_planNumber].price);
        INFT(NFTContract).changeDeadline(tokenId, plans[_planNumber].months);
    }

    function renewStorage(uint256 tokenId, uint256 _planNumber)
        external
        onlyAdmin
    {
        INFT(NFTContract).changeDeadline(tokenId, plans[_planNumber].months);
    }

    function setAmount(Struct.NFTSell memory seller, uint256 amount) internal {
        //Counter used
        require(!allSold[seller.winery], "CU");
        uint256 leftCounter = leftAmount[seller.winery];
        if (leftCounter == 0) {
            leftCounter = seller.amount - amount;
        } else {
            leftCounter = leftCounter - amount;
        }
        require(leftCounter >= 0, "ALZ"); //Amount left less than zero

        leftAmount[seller.winery] = leftCounter;
        if (leftCounter == 0) allSold[seller.winery] = true;
    }

    function _msgSender()
        internal
        view
        override(BasicMetaTransaction)
        returns (address sender)
    {
        return super._msgSender();
    }
}
