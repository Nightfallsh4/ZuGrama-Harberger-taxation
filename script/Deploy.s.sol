// SPDX-License-Identifier: GPL-v3
pragma solidity 0.8.26;

import { Script } from "forge-std/Script.sol";
import { Auction } from "src/Auction.sol";
import { Harberger } from "src/Harberger.sol";
import { SBT } from "src/SBT.sol";

contract Deploy is Script {
    Auction auction;
    Harberger harberger;
    SBT sbt;

    function run() external {
        vm.startBroadcast();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public returns (address _auction, address _harberger, address _sbt) {
        address auctioner = vm.envAddress("AUCTIONER_ADDRESS");
        auction = new Auction(auctioner);
        harberger = new Harberger();
        sbt = new SBT("ZuGrama-1 Assets", "Zu1Assets", address(harberger));

        _auction = address(auction);
        _harberger = address(harberger);
        _sbt = address(sbt);
    }
}
