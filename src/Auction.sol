// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "src/utils/Errors.sol";
import "src/utils/Events.sol";

contract Auction {
    struct AssetDetails {
        bool isAsset;
        uint64 auctionStartTime;
        uint64 auctionEndTime;
        address currentBidder;
        uint256 currentBid;
        uint256 minBid;
    }

    address immutable auctioner;

    mapping(address asset => mapping(uint256 assetId => AssetDetails details)) public assets;

    constructor(address _auctioner) {
        auctioner = _auctioner;
    }

    modifier onlyAuctioner() {
        if (msg.sender != auctioner) {
            revert Auction_NotAuctioner();
        }
        _;
    }

    function bid(address _asset, uint256 _assetId, uint256 _bidAmount) external {
        AssetDetails memory assetDetails = assets[_asset][_assetId];
        checkAssetBidStatus(assetDetails);

        if (_bidAmount < assetDetails.minBid) {
            revert Auction_LessThanMinBid();
        }

        if (assetDetails.currentBid >= _bidAmount) {
            revert Auction_BidTooLess();
        }
    }

    function setAssetDetails(address _assetAddress, uint256 _assetId, uint256 _minBid) external onlyAuctioner {
        assets[_assetAddress][_assetId] = AssetDetails({
            isAsset: true,
            auctionStartTime: 0,
            auctionEndTime: 0,
            currentBidder: address(0),
            currentBid: 0,
            minBid: _minBid
        });
        emit Auction_AssetSet(_assetAddress, _assetId, _minBid);
    }

    function checkAssetBidStatus(AssetDetails memory assetDetails) internal view {
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
