// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { SBT } from "src/SBT.sol";
import "src/utils/Events.sol";

contract SBTFactory {
    address immutable harberger;

    constructor(address _harberger) {
        harberger = _harberger;
    }

    function createSbtAsset(
        string memory _name,
        string memory _symbol,
        address _initialOwner
    )
        external
        returns (address assetAddress)
    {
        SBT sbtAsset = new SBT(_name, _symbol, harberger, _initialOwner);

        assetAddress = address(sbtAsset);

        emit SBTFactory_New_Asset(assetAddress, _initialOwner, _name, _symbol);
    }
}
