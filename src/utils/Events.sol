// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Auction Event
event Auction_AssetSet(address indexed assetAddress, uint256 indexed assetId, uint256 indexed minBid);

event Auction_Started(address indexed assetAddress, uint256 indexed assetId, uint256 indexed auctionEndTime);
