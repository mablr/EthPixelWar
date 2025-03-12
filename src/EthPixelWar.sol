// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin-contracts-5.1.0/access/Ownable.sol";

struct Pixel {
    address owner;
    uint256 highestBid;
    uint8 r;
    uint8 g;
    uint8 b;
}

contract EthPixelWar is Ownable {
    bool public immutable liteMode;
    uint16 public immutable dimX;
    uint16 public immutable dimY;
    bool public pixelWarIsActive;
    mapping(uint16 => Pixel) public grid;
    mapping(address => uint256) public pendingWithdrawals;

    event PixelBid(uint16 pixelId, address bidder, uint256 bidAmount);
    event ColorUpdated(uint16 pixelId, uint8 r, uint8 g, uint8 b);
    event PixelWarEnded();

    constructor(uint16 _dimX, uint16 _dimY, bool _liteMode, address _initialOwner) Ownable(_initialOwner) {
        require(_dimX > 0 && _dimX <= 255 && _dimY > 0 && _dimY <= 255, "Grid dimensions must be between 1 and 255");
        liteMode = _liteMode;
        dimX = _dimX;
        dimY = _dimY;
        pixelWarIsActive = true;
    }

    modifier validPixelId(uint16 pixelId) {
        require(pixelId < dimX * dimY, "Invalid pixel id");
        _;
    }

    modifier onlyActivePixelWar() {
        require(pixelWarIsActive, "The pixel war has ended");
        _;
    }

    modifier onlyPixelOwner(uint16 pixelId) {
        require(msg.sender == grid[pixelId].owner, "Not the pixel owner");
        _;
    }

    modifier validBid(uint16 pixelId) {
        require(msg.value > grid[pixelId].highestBid, "Bid must be higher than current highest bid");
        _;
    }

    function bid(uint16 pixelId) public payable validPixelId(pixelId) validBid(pixelId) onlyActivePixelWar {
        Pixel storage pixel = grid[pixelId];
        if (pixel.owner != address(0)) {
            pendingWithdrawals[pixel.owner] += pixel.highestBid;
        }
        pixel.owner = msg.sender;
        pixel.highestBid = msg.value;

        emit PixelBid(pixelId, msg.sender, msg.value);
    }

    function withdraw() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds to withdraw");
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function updateColor(uint16 pixelId, uint8 red, uint8 green, uint8 blue)
        public
        validPixelId(pixelId)
        onlyPixelOwner(pixelId)
        onlyActivePixelWar
    {
        if (!liteMode) {
            grid[pixelId].r = red;
            grid[pixelId].g = green;
            grid[pixelId].b = blue;
        }
        emit ColorUpdated(pixelId, red, green, blue);
    }

    function endPixelWar() public onlyOwner onlyActivePixelWar {
        pixelWarIsActive = false;

        for (uint16 pixelId = 0; pixelId < dimX * dimY; pixelId++) {
            Pixel storage pixel = grid[pixelId];
            if (pixel.owner != address(0) && pixel.highestBid > 0) {
                pendingWithdrawals[pixel.owner] += pixel.highestBid;
            }
        }

        emit PixelWarEnded();
    }

    function getGrid() public view returns (Pixel[] memory) {
        Pixel[] memory pixels = new Pixel[](dimX * dimY);
        for (uint16 pixelId = 0; pixelId < dimX * dimY; pixelId++) {
            pixels[pixelId] = grid[pixelId];
        }
        return pixels;
    }
}
