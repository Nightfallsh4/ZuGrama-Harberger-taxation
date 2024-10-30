// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "src/utils/Errors.sol";

contract Auction {
    struct AssetDetails {
        bool isAsset;
        bool isSold;
        uint64 auctionStartTime;
        uint64 auctionEndTime;
        address currentBidder;
        uint256 currentBid;
        uint256 minBid;
    }

    mapping(address asset => mapping(uint256 assetId => AssetDetails details)) public assets;

    function bid(address _asset, uint256 _assetId, uint256 _bidAmount) external {
        AssetDetails memory assetDetails = assets[_asset][_assetId];
        checkAssetStatus(assetDetails);

        if (_bidAmount < assetDetails.minBid) {
            revert Auction_LessThanMinBid();
        }
    }

    function checkAssetStatus(AssetDetails memory assetDetails) internal view {
        // Checks if Asset is Authorised
        if (!assetDetails.isAsset) {
            revert Auction_NotAsset();
        }

        // Check if autionEndTime and auctionStartTime aren't zero, which mean the aution time isn't set yet
        if (assetDetails.auctionEndTime == 0 || assetDetails.auctionStartTime == 0) {
            revert Auction_TimeNotValid();
        }

        // Check if autionStartTime is not greater than current timestamp, ie Auction not started yet
        if (assetDetails.auctionStartTime > block.timestamp) {
            revert Auction_NotStarted();
        }

        // Check if auctionEnd Time is not less than current timestamp, ie Auction hasn't ended yet
        if (assetDetails.auctionEndTime < block.timestamp) {
            revert Auction_Ended();
        }
    }
}
