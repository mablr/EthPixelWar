// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {EthPixelWar} from "../src/EthPixelWar.sol";

contract DeployLiteMode is Script {
    address public initialOwner = msg.sender;
    uint16 public gridSize = 10;
    bool public liteMode = false;

    function run() external returns (EthPixelWar) {
        vm.startBroadcast();
        EthPixelWar ethPixelWar = new EthPixelWar(gridSize, liteMode, initialOwner);
        vm.stopBroadcast();
        console.log("Deployed EthPixelWar contract at:", address(ethPixelWar));
        return ethPixelWar;
    }
}
