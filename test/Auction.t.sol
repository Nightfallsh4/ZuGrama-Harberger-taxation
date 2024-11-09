// SPDX-License-Identifier: GPL-v3
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { Deploy } from "script/Deploy.s.sol";
import { Auction } from "src/Auction.sol";
import { Harberger } from "src/Harberger.sol";
import { SBT } from "src/SBT.sol";
import "src/utils/Errors.sol";

contract AuctionTest is Test {
    struct AssetDetails {
        bool isAsset;
        uint64 auctionStartTime;
        uint64 auctionEndTime;
        address currentBidder;
        uint256 currentBid;
        uint256 minBid;
    }

    Auction auction;
    Harberger harberger;
    SBT sbt;

    address auctioner;

    function setUp() external {
        Deploy deploy = new Deploy();
        (address _auction, address _harberger, address _sbt, Deploy.Config memory config) = deploy.deploy();
        auction = Auction(_auction);
        harberger = Harberger(_harberger);
        sbt = SBT(_sbt);
        auctioner = config.auctioner;
    }

    function test_Auction_RevertIfNotAuctioner() external {
        vm.expectRevert(Auction_NotAuctioner.selector);
        auction.setAssetDetails(address(sbt), 1, 1);
    }

    function test_Auction_AssetsSet() external {
        hoax(auctioner, 10 ether);
        auction.setAssetDetails(address(sbt), 1, 1);

        Auction.AssetDetails memory assetDetails = auction.getAssetDetails(address(sbt), 1);

        assertEq(assetDetails.isAsset, true);
        assertEq(assetDetails.minBid, 1);
    }

    function test_Auction_RevertIfNotAsset() external {
        vm.expectRevert(Auction_NotAsset.selector);
        auction.bid(address(sbt), 1, 1 ether);
    }

    modifier setAsset() {
        hoax(auctioner, 10 ether);
        auction.setAssetDetails(address(sbt), 1, 1);
        _;
    }

    function test_Auction_RevertIfInvalidTime() external setAsset {
        vm.expectRevert(Auction_TimeNotValid.selector);
        auction.bid(address(sbt), 1, 2);
    }
}
