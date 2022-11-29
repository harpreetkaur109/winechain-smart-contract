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
    mapping(uint256 => Struct.planDetails) internal currentPlan;
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
        require(
            _NFTContract != address(0) &&
                _admin != address(0) &&
                _usdc != address(0),
            "ZA"
        ); //Zero Address
        NFTContract = _NFTContract;
        admin = _admin;
        planNumber = 1;
        usdc = IERC20(_usdc);
    }

    function createNFT(Struct.NFTData calldata NFT) external onlyAdmin {
        require(NFT.winery != address(0), "ZA"); //Zero Address
        require(NFT.releaseDate > block.timestamp, "ID"); //Invalid Date
        INFT(NFTContract).bulkMint(NFT);
    }

    function buyNFT(Struct.NFTSell calldata sell, uint256 amount) external {
        require(sell.winery != address(0), "ZA"); //Zero Address
        require(sell.seller != address(0), "ZA"); //Zero Address
        if (sell.seller == sell.winery) {
            setAmount(sell, amount);
            usdc.transferFrom(msg.sender, admin, amount * sell.price);

            for (
                uint256 i = currentIndex[sell.seller];
                i < currentIndex[sell.seller] + amount;
                i++
            ) {
                IERC721Upgradeable(NFTContract).transferFrom(
                    sell.seller,
                    msg.sender,
                    sell.tokenIds[i]
                );
            }

            currentIndex[sell.seller] += amount;
        } else {
            uint256 daysLeft;
            uint256 Amount;
            uint256 total;
            setAmount(sell, amount);
            uint256 transferAmount = amount * sell.price;
            usdc.transferFrom(msg.sender, admin, (transferAmount * 10) / 100);
            usdc.transferFrom(
                msg.sender,
                sell.winery,
                (transferAmount * 20) / 100
            );
            usdc.transferFrom(
                msg.sender,
                sell.seller,
                transferAmount - ((transferAmount * 30) / 100)
            );
            for (
                uint256 i = currentIndex[sell.seller];
                i < currentIndex[sell.seller] + amount;
                i++
            ) {
                IERC721Upgradeable(NFTContract).transferFrom(
                    sell.seller,
                    msg.sender,
                    sell.tokenIds[i]
                );
                daysLeft =
                    ((INFT(NFTContract).checkDeadline(sell.tokenIds[i]) - block.timestamp) /
                    864000)+1;
                Amount =
                    ((currentPlan[i].months/86400) / currentPlan[i].price) *
                    daysLeft;
                total += Amount;
                INFT(NFTContract).setDeadline(sell.tokenIds[i], block.timestamp);
            }
            usdc.transferFrom(admin, sell.seller, total);
            currentIndex[sell.seller] += amount;
        }
    }

    function createPlan(Struct.planDetails calldata _planDetails)
        external
        onlyAdmin
    {
        require(_planDetails.months != 0, "IV"); //Invalid Value
        require(_planDetails.price != 0, "IV"); //Invalid Value
        plans[planNumber].months = _planDetails.months;
        plans[planNumber].price = _planDetails.price;
        planNumber++;
    }

    function changereleaseDate(uint256 tokenId, uint256 _newDate)
        external
        onlyAdmin
    {
        require(_newDate > block.timestamp, "ID"); //Invalid Date
        INFT(NFTContract).changeReleaseDate(tokenId, _newDate);
    }

    function buyStorage(uint256 tokenId, uint256 _planNumber) external {
        if (block.timestamp > INFT(NFTContract).checkDeadline(tokenId)) {
            uint256 timeDifference = block.timestamp -
                INFT(NFTContract).checkDeadline(tokenId);
            uint256 time = (timeDifference / plans[_planNumber].months) + 1;
            currentPlan[tokenId] = plans[_planNumber];
            usdc.transferFrom(
                msg.sender,
                admin,
                plans[_planNumber].price * time
            );
            INFT(NFTContract).increaseDeadline(
                tokenId,
                plans[_planNumber].months + time
            );
        } else {
            usdc.transferFrom(msg.sender, admin, plans[_planNumber].price);
            currentPlan[tokenId] = plans[_planNumber];
            INFT(NFTContract).increaseDeadline(
                tokenId,
                plans[_planNumber].months
            );
        }
    }

    function renewStorage(uint256 tokenId, uint256 _planNumber)
        external
        onlyAdmin
    {
        currentPlan[tokenId] = plans[_planNumber];
        INFT(NFTContract).increaseDeadline(tokenId, plans[_planNumber].months);
    }

    function checkStorage(uint256 tokenId) external {
        if(block.timestamp > INFT(NFTContract).checkDeadline(tokenId)+31557600)
    }

    function setAmount(Struct.NFTSell memory seller, uint256 amount) internal {
        require(!allSold[seller.seller], "AS"); //All Sold
        uint256 _leftAmount = leftAmount[seller.winery];
        if (_leftAmount == 0) {
            _leftAmount = seller.amount - amount;
        } else {
            _leftAmount = _leftAmount - amount;
        }
        require(_leftAmount >= 0, "ALZ"); //Amount left less than zero

        leftAmount[seller.winery] = _leftAmount;
        if (_leftAmount == 0) allSold[seller.winery] = true;
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
