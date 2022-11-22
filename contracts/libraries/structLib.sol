// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

library Struct {
    struct NFTData {
        address winery;
        uint256 releaseDate;
        uint256 amount;
        uint256 deadline;
        uint256 royaltyAmount;
        string URI;
    }

    struct NFTSell {
        address winery;
        address seller;
        uint256[] tokenIds;
        uint256 price;
        uint256 amount;
    }

    struct planDetails {
        uint256 months;
        uint256 price;
    }
}
