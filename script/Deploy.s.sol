// SPDX-License-Identifier: GPL-v3
pragma solidity 0.8.26;

import { Script } from "forge-std/Script.sol";
import { Auction } from "src/Auction.sol";
import { Harberger } from "src/Harberger.sol";
import { SBT } from "src/SBT.sol";
import  { SBTFactory } from "src/SBTFactory.sol";

contract Deploy is Script {
    struct Config {
        address auctioner;
        address USDC;
        address admin;
    }

    Auction auction;
    Harberger harberger;
    SBT sbt;
    SBTFactory sbtFactory;

    function run() external {
        vm.startBroadcast();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public returns (address _auction, address _harberger, address _sbt, Config memory config) {
        config = getConfig();
        auction = new Auction(config.auctioner, config.USDC);
        harberger = new Harberger(config.admin, address(auction), config.USDC);
        sbt = new SBT("ZuGrama-1 Assets", "Zu1Assets", address(harberger), msg.sender);
        sbtFactory =  new SBTFactory(address(harberger));

        _auction = address(auction);
        _harberger = address(harberger);
        _sbt = address(sbt);
    }

    function getConfig() internal view returns (Config memory) {
        return Config({
            auctioner: vm.envAddress("AUCTIONER_ADDRESS"),
            USDC: address(2513),
            admin: vm.envAddress("ADMIN_ADDRESS")
        });
    }
}
