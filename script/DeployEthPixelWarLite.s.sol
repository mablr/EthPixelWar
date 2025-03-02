// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std-1.9.6/src/Script.sol";
import {console} from "forge-std-1.9.6/src/console.sol";
import {EthPixelWar} from "../src/EthPixelWar.sol";

contract DeployEthPixelWarLite is Script {
    uint16 public gridSize = 10;
    bool public liteMode = true;

    function run() external returns (EthPixelWar) {
        vm.startBroadcast();
        EthPixelWar ethPixelWar = new EthPixelWar(gridSize, liteMode, msg.sender);
        vm.stopBroadcast();
        console.log("Deployed EthPixelWar (lite) contract at:", address(ethPixelWar));
        return ethPixelWar;
    }
}
