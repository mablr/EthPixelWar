// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EthPixelWar} from "../src/EthPixelWar.sol";

contract EthPixelWarScript is Script {
    EthPixelWar public eth_pixel_war;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        eth_pixel_war = new EthPixelWar(3);

        vm.stopBroadcast();
    }
}
