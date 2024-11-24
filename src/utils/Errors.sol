// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// SBT Errors
error SBT_Function_Disabled();
error SBT_Only_Harberger();

// Auction Errors
error Auction_NotAsset();
error Auction_TimeNotValid();
error Auction_NotStarted();
error Auction_Ended();
error Auction_LessThanMinBid();
error Auction_BidTooLess();
error Auction_NotAuctioner();
error Auction_HasntEnded();
error Auction_NotWinningBidder();

// Harberger Errors
error Harberger_NotAuction();
error Harberger_NotAdmin();
error Harberger_AssetAlreadyExists();
error Harberger_CantExceed100Percent();
