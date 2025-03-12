// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std-1.9.6/src/Test.sol";
import {EthPixelWar, Pixel} from "../src/EthPixelWar.sol";

contract EthPixelWarTest is Test {
    EthPixelWar public epw;

    address alice;
    address bob;

    function setUp() public {
        alice = address(0x123);
        bob = address(0x456);
        epw = new EthPixelWar(3, 4, false, alice);

        // Label the addresses for easier readability in logs
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        // Fund test addresses with ETH for bidding
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_OutOfBound_Modifier() public {
        vm.startPrank(alice); // Set Alice as the caller

        vm.expectRevert("Invalid pixel id");
        epw.bid(256); // Invalid pixel id, should revert

        vm.expectRevert("Invalid pixel id");
        epw.updateColor(256, 255, 255, 255); // Invalid pixel id, should revert

        vm.stopPrank();
    }

    function test_ValidBid_Modifier() public {
        // Alice places a bid on cell (1,1)
        vm.startPrank(alice);
        epw.bid{value: 2 ether}(1); // Alice bids 2 ether for cell (1,1)
        vm.stopPrank();

        // Bob places a bid on cell (1,1)
        vm.startPrank(bob);
        vm.expectRevert("Bid must be higher than current highest bid");
        epw.bid{value: 1 ether}(1); // Bob bids insufficient amount for cell (1,1)
        vm.stopPrank();
    }

    function test_onlyPixelOwner_Modifier() public {
        // Alice places a bid on cell (1,1)
        vm.startPrank(alice);
        epw.bid{value: 1 ether}(1); // Alice bids 1 ether for cell (1,1)
        vm.stopPrank();

        // Bob tries to update the color, but he's not the owner
        vm.startPrank(bob);
        // Expect Bob's updateColor attempt to fail
        vm.expectRevert("Not the pixel owner");
        epw.updateColor(1, 255, 0, 0); // Bob can't update, should revert

        vm.stopPrank();

        // Alice, as the owner, should be able to update the color
        vm.startPrank(alice);
        epw.updateColor(1, 0, 255, 0); // Alice is the owner, should succeed
        vm.stopPrank();
    }

    function test_onlyActivePixelWar_Modifier() public {
        // Alice places a bid on cell (1,1)
        vm.startPrank(alice);
        epw.bid{value: 1 ether}(1); // Alice bids 1 ether for cell (1,1)

        // Contract owner ends the pixel war
        epw.endPixelWar();

        // Alice tries to update the color, but the pixel war is not active anymore
        // Expect Alice's updateColor attempt to fail
        vm.expectRevert("The pixel war has ended");
        epw.updateColor(1, 255, 0, 0); // Alice can't update, should revert

        // Expect Alice's bid attempt to fail
        vm.expectRevert("The pixel war has ended");
        epw.bid{value: 1 ether}(2); // Alice can't bid, should revert

        // War has already ended
        vm.expectRevert("The pixel war has ended");
        epw.endPixelWar();
        vm.stopPrank();
    }

    function test_beatenBid() public {
        // Alice places a bid on cell (1,1)
        vm.startPrank(alice);
        epw.bid{value: 1 ether}(1); // Alice bids 1 ether for cell (1,1)
        vm.stopPrank();

        // Bob places an higher bid on cell (1,1)
        vm.startPrank(bob);
        epw.bid{value: 2 ether}(1); // Bob bids 2 ether for cell (1,1)
        vm.stopPrank();

        // Alice can now withdraw it's beaten bid
        vm.startPrank(alice);
        epw.withdraw();
        vm.stopPrank();

        // While bob has no funds to withdraw for the moment
        vm.startPrank(bob);
        vm.expectRevert("No funds to withdraw");
        epw.withdraw();
        vm.stopPrank();
    }

    function test_endWar() public {
        // Alice places a bid on cells (1,1) and (1,2)
        vm.startPrank(alice);
        epw.bid{value: 1 ether}(1); // Alice bids 1 ether for cell (1,1)
        epw.bid{value: 1 ether}(2); // Alice bids 1 ether for cell (1,1)
        vm.stopPrank();

        // Bob places a bid on cell (2,1)
        vm.startPrank(bob);
        epw.bid{value: 2 ether}(2); // Bob bids 2 ether for cell (1,1)
        vm.stopPrank();

        // Only the owner can end the pixel war
        vm.startPrank(bob);
        vm.expectRevert();
        epw.endPixelWar();
        vm.stopPrank();

        // Contract owner ends the pixel war
        vm.startPrank(alice);
        epw.endPixelWar();
        vm.stopPrank();

        // Alice and Bob can now withdraw their bids
        vm.startPrank(alice);
        epw.withdraw();
        vm.stopPrank();
        vm.startPrank(bob);
        epw.withdraw();
        vm.stopPrank();
    }

    function test_getPixel() public {
        // Alice places a bid on cell (1,1) and updates its color
        vm.startPrank(alice);
        epw.bid{value: 3 ether}(1); // Alice bids 1 ether for cell (1,1)
        epw.updateColor(1, 255, 0, 0);
        vm.stopPrank();

        (address pixelOwner, uint256 pixelHighestBid, uint8 red, uint8 green, uint8 blue) = epw.grid(1);

        assertEq(pixelOwner, alice);
        assertEq(pixelHighestBid, 3 ether);
        assertEq(red, 255);
        assertEq(green, 0);
        assertEq(blue, 0);
    }

    function test_getGrid() public {
        // Alice places a bid on cell (1,1) and updates its color
        vm.startPrank(alice);
        epw.bid{value: 3 ether}(5); // Alice bids 1 ether for cell (1,1)
        epw.updateColor(5, 255, 0, 0);
        vm.stopPrank();

        Pixel[] memory pixels = epw.getGrid();
        assertEq(pixels.length, 12);
        assertEq(pixels[5].owner, alice);
        assertEq(pixels[5].highestBid, 3 ether);
        assertEq(pixels[5].r, 255);
        assertEq(pixels[5].g, 0);
        assertEq(pixels[5].b, 0);

        assertEq(pixels[6].owner, address(0));
        assertEq(pixels[6].highestBid, 0);
        assertEq(pixels[6].r, 0);
        assertEq(pixels[6].g, 0);
        assertEq(pixels[6].b, 0);
    }
}
