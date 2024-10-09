// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EthPixelWar} from "../src/EthPixelWar.sol";

contract CounterTest is Test {
    EthPixelWar public epw;

    address alice;
    address bob;

    function setUp() public {
        epw = new EthPixelWar(3);

        alice = address(0x123);
        bob = address(0x456);

        // Label the addresses for easier readability in logs
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        // Fund test addresses with ETH for bidding
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_OutOfBound_Modifier() public {
        vm.startPrank(alice); // Set Alice as the caller

        vm.expectRevert("Invalid coordinates");
        epw.bid(15, 15); // Invalid coordinates, should revert

        vm.expectRevert("Invalid coordinates");
        epw.updateColor(15, 15, 255, 255, 255); // Invalid coordinates, should revert

        vm.stopPrank();
    }

    function test_OnlyOwner_Modifier() public {
        // Alice places a bid on cell (1,1)
        vm.startPrank(alice);
        epw.bid{value: 1 ether}(1, 1); // Alice bids 1 ether for cell (1,1)
        vm.stopPrank();

        // Bob tries to update the color, but he's not the owner
        vm.startPrank(bob);
        // Expect Bob's updateColor attempt to fail
        vm.expectRevert("Not the pixel owner");
        epw.updateColor(1, 1, 255, 0, 0); // Bob can't update, should revert

        vm.stopPrank();

        // Alice, as the owner, should be able to update the color
        vm.startPrank(alice);
        epw.updateColor(1, 1, 0, 255, 0); // Alice is the owner, should succeed
        vm.stopPrank();
    }
}
