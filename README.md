# Harberger Taxation

**This repo consists of a governance and taxation experiment to be conducted at ZuGram using Harberger taxes.**

An Asset is represented by a Soulbound token(NFT) whose ownership can only be transferred after a successful Harberger buyout. The Soulbound Token is initially auctioned and minted by an Auction contract.  After the auction is complete, to claim the Asset the winning bidder will have to set their initial value of the SBT. 

A percentage of that Value they set, will have to be paid as taxes.

## Getting Started

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

## Contracts
There are three contracts which contain the initial auctioning mechanism, Harberger mechanism, and a Soulbound Token denoting the current ownership of the asset.

### Auction Contract 

