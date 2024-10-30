// SPDX-License-Identifier: GPL-v3
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { Deploy } from "script/Deploy.s.sol";
import { Auction } from "src/Auction.sol";
import { Harberger } from "src/Harberger.sol";
import { SBT } from "src/SBT.sol";
import "src/utils/Errors.sol";

contract AuctionTest is Test {
    Auction auction;
    Harberger harberger;
    SBT sbt;

    function setUp() external {
        Deploy deploy = new Deploy();
        (address _auction, address _harberger, address _sbt) = deploy.deploy();
        auction = Auction(_auction);
        harberger = Harberger(_harberger);
        sbt = SBT(_sbt);
    }

    function test_Auction_RevertIfNotAuctioner() external {
        vm.expectRevert(Auction_NotAuctioner.selector);
        auction.setAssetDetails(address(sbt), 1, 1);
    }

    function test_Auction_RevertIfNotAsset() external {
        vm.expectRevert(Auction_NotAsset.selector);
        auction.bid(address(sbt), 1, 1 ether);
    }

    // function test_Auction_Revert()  returns () {

    // }
}
