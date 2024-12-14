// SPDX-License-Identifier: GPL-v3
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { Deploy } from "script/Deploy.s.sol";
import { Auction } from "src/Auction.sol";
import { Harberger } from "src/Harberger.sol";
import { SBT } from "src/SBT.sol";
import { MockUsdc } from "test/mocks/MockUsdc.sol";
import "src/utils/Errors.sol";

contract HarbergerTest is Test {
    Auction auction;
    Harberger harberger;
    SBT sbt;
    uint256 tokenId = 1;

    MockUsdc USDC;

    uint256 constant HUNDRED_USDC = 100_000_000; // 10 USDC in 6 decimals
    uint256 constant TEN_USDC = 10_000_000; // 10 USDC in 6 decimals
    uint256 constant TWENTY_USDC = 20_000_000;
    uint256 constant ONE_USDC = 1_000_000;
    uint256 constant ONE_TENTH_USDC = 100_000; // 1/10 of USDC for Tax Rate
    address auctioner;

    address user1 = makeAddr("USER_1");
    address user2 = makeAddr("USER_2");

    uint256 constant ASSET_VALIDITY = 10 days;
    uint256 constant QUARTER_ASSET_VALIDITY = 2.5 days;
    uint256 constant HALF_ASSET_VALIDITY = 5 days;
    uint256 constant AUCTION_DURATION = 1 hours;

    function setUp() external {
        Deploy deploy = new Deploy();
        (address _auction, address _harberger, address _sbt,, address _USDC, Deploy.Config memory config) =
            deploy.deploy();

        auction = Auction(_auction);
        harberger = Harberger(_harberger);
        sbt = SBT(_sbt);

        USDC = MockUsdc(_USDC);

        auctioner = config.auctioner;

        USDC.mint(user1, HUNDRED_USDC);

        hoax(auctioner, 10 ether);
        auction.setHarberger(address(harberger));

        hoax(config.admin, 10 ether);
        harberger.setTaxRate(ONE_TENTH_USDC);
    }

    modifier setAsset() {
        hoax(auctioner, 10 ether);
        auction.setAssetDetails(address(sbt), 1, 1);
        _;
    }

    modifier startAuctionAndValidity(uint256 _tokenId, uint256 _auctionDuration, uint256 _assetValidityDuration) {
        hoax(auctioner, 10 ether);
        auction.startAuctionAndValidity(address(sbt), _tokenId, _auctionDuration, _assetValidityDuration);
        _;
    }

    function test_InitialMint() public setAsset startAuctionAndValidity(tokenId, AUCTION_DURATION, ASSET_VALIDITY) {
        uint256 auctionStartedTime = uint64(block.timestamp);

        hoax(user1, 100 ether);
        USDC.approve(address(auction), TEN_USDC + (2 * ONE_USDC)); // 10 USDC is amount. 2 USDC is Tax for 20 USDC
            // initial Value

        // Make bid of 10 USDC
        hoax(user1);
        auction.bid(address(sbt), tokenId, TEN_USDC, TWENTY_USDC); // Auction bid is 10 USDC and initial Value to set is
            // 20 USDC

        // Wait for Auction to end
        skip(AUCTION_DURATION);
        uint256 expectedValidFrom = uint64(block.timestamp);

        // Claim Asset
        hoax(user1);
        auction.claim(address(sbt), tokenId, user1);

        Harberger.HarbergerDetails memory harbergerDetails = harberger.getHarbegerDetails(address(sbt), tokenId);
        assertEq(harbergerDetails.validFrom, expectedValidFrom);
        assertEq(harbergerDetails.updatedAt, expectedValidFrom);
        assertEq(harbergerDetails.validTill, auctionStartedTime + ASSET_VALIDITY);
        assertEq(harbergerDetails.value, TWENTY_USDC);

        assertEq(USDC.balanceOf(address(harberger)), TEN_USDC + (2 * ONE_USDC));
        assertEq(sbt.ownerOf(tokenId), user1);
    }

    function initialMint() internal setAsset startAuctionAndValidity(tokenId, AUCTION_DURATION, ASSET_VALIDITY) {
        
        hoax(user1, 100 ether);
        USDC.approve(address(auction), TEN_USDC + (2 * ONE_USDC)); // 10 USDC is amount. 2 USDC is Tax for 20 USDC
            // initial Value

        // Make bid of 10 USDC
        hoax(user1);
        auction.bid(address(sbt), tokenId, TEN_USDC, TWENTY_USDC); // Auction bid is 10 USDC and initial Value to set is
            // 20 USDC

        // Wait for Auction to end
        skip(AUCTION_DURATION);
        

        // Claim Asset
        hoax(user1);
        auction.claim(address(sbt), tokenId, user1);
    }

    function test_startBuyout() external {
        initialMint();

        skip(QUARTER_ASSET_VALIDITY);
        uint256 currentValue = harberger.getCurrentValueOfAsset(address(sbt), tokenId);
    }
}
