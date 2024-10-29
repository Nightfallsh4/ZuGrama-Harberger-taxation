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

    function deploy() public {
        auction = new Auction();
        harberger = new Harberger();
        sbt = new SBT("ZuGrama-1 Assets", "Zu1Assets", address(harberger));
    }
}
