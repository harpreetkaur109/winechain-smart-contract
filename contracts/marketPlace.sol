//SPDX-License_Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./libraries/structLib.sol";
import "./Interfaces/INFT.sol";
import "./Relayer/BasicMetaTransaction.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "hardhat/console.sol";

contract marketPlace is EIP712Upgradeable,BasicMetaTransaction {

    //  bytes32 public constant WINECHAIN_SELLER_HASH =
    //  0x51578850e098d13a094707a5ac92c49e129a0105cf9dd73242d806c6226cb33b;

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
    ) external initializer{
        __EIP712_init("WineChain_NFT_Voucher", "1");

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

    function buyNFT(Struct.NFTSell calldata sell) external {
        require(sell.winery != address(0), "ZA"); //Zero Address
        require(sell.seller != address(0), "ZA"); //Zero Address        note if signature condition put ahead no need for this require
        require(sell.seller == _verifySeller(sell), "ISA");

        if (sell.seller == sell.winery) {
            // setAmount(sell, amount);
            usdc.transferFrom(msg.sender, admin, sell.price);
                IERC721Upgradeable(NFTContract).transferFrom(
                    sell.seller,
                    msg.sender,
                    sell.tokenId
                );
          
        } else {
            uint256 daysLeft;
            uint256 Amount;
            uint256 total;
            // setAmount(sell, amount);
            require(currentPlan[sell.tokenId].months > 0, "NS");   //check

            usdc.transferFrom(msg.sender, admin, (sell.price * 10) / 100);
            usdc.transferFrom(
                msg.sender,
                sell.winery,
                (sell.price * 20) / 100
            );
            usdc.transferFrom(
                msg.sender,
                sell.seller,
                sell.price - ((sell.price * 30) / 100)
            );
          
                IERC721Upgradeable(NFTContract).transferFrom(
                    sell.seller,
                    msg.sender,
                    sell.tokenId
                );
                daysLeft =
                    ((INFT(NFTContract).checkDeadline(sell.tokenId) - block.timestamp) /
                    864000)+1;

                // reembursement amount
                Amount =
                    ((currentPlan[sell.tokenId].months*2630000/86400) / currentPlan[sell.tokenId].price) *
                    daysLeft;
                total += Amount;
                INFT(NFTContract).setDeadline(sell.tokenId, block.timestamp);
            
            // usdc.transferFrom(admin, sell.seller, total);
        }
    }

     /**
     * @notice Returns a hash of the given HeftyVerseSeller, prepared using EIP712 typed data hashing rules.
     * @param sell is a HeftyVerseSeller to hash.
     */
    function _hashSeller(Struct.NFTSell calldata sell)
        internal
        view
        returns (bytes32)
    {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "NFTSell(address winery,address seller,uint256 tokenId,uint256 price)"
                        ),
                        sell.winery,
                        sell.seller,
                        sell.tokenId,
                        sell.price
                    )
                )
            );
    }

     /**
     * @notice Verifies the signature for a given HeftyVerseSeller, returning the address of the signer.
     * @dev Will revert if the signature is invalid. Does not verify that the signer is owner of the NFT.
     * @param sell is a HeftyVerseSeller describing the NFT to be sold
     */
    function _verifySeller(Struct.NFTSell calldata sell)
        internal
        view
        returns (address)
    {
        bytes32 digest = _hashSeller(sell);
        return ECDSAUpgradeable.recover(digest, sell.signature);
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
            console.log("deadline",INFT(NFTContract).checkDeadline(tokenId));
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

    // function checkStorage(uint256 tokenId) external {
    //     if(block.timestamp > INFT(NFTContract).checkDeadline(tokenId)+31557600);
    // }

    // function setAmount(Struct.NFTSell memory seller, uint256 amount) internal {
    //     require(!allSold[seller.seller], "AS"); //All Sold
    //     uint256 _leftAmount = leftAmount[seller.winery];
    //     if (_leftAmount == 0) {
    //         _leftAmount = seller.amount - amount;
    //     } else {
    //         _leftAmount = _leftAmount - amount;
    //     }
    //     require(_leftAmount >= 0, "ALZ"); //Amount left less than zero

    //     leftAmount[seller.winery] = _leftAmount;
    //     if (_leftAmount == 0) allSold[seller.winery] = true;
    // }

    function _msgSender()
        internal
        view
        override(BasicMetaTransaction)
        returns (address sender)
    {
        return super._msgSender();
    }
}
