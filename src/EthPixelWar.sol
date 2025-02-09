// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract EthPixelWar is Ownable {
    struct Pixel {
        address owner;
        uint256 highestBid;
        uint8 r;
        uint8 g;
        uint8 b;
    }

    bool public liteMode;
    bool public pixelWarIsActive;
    uint16 public gridSize;
    mapping(uint16 => mapping(uint16 => Pixel)) public grid;
    mapping(address => uint256) public pendingWithdrawals;

    event PixelBid(uint16 x, uint16 y, address bidder, uint256 bidAmount);
    event ColorUpdated(uint16 x, uint16 y, uint8 r, uint8 g, uint8 b);
    event PixelWarEnded();

    constructor(uint16 _gridSize, bool _liteMode, address _initialOwner) Ownable(_initialOwner) {
        gridSize = _gridSize;
        liteMode = _liteMode;
        pixelWarIsActive = true;
    }

    modifier validCoordinates(uint16 x, uint16 y) {
        require(x < gridSize && y < gridSize, "Invalid coordinates");
        _;
    }

    modifier onlyActivePixelWar() {
        require(pixelWarIsActive, "The pixel war has ended");
        _;
    }

    modifier onlyPixelOwner(uint16 x, uint16 y) {
        require(msg.sender == grid[x][y].owner, "Not the pixel owner");
        _;
    }

    modifier validBid(uint16 x, uint16 y) {
        require(msg.value > grid[x][y].highestBid, "Bid must be higher than current highest bid");
        _;
    }

    function bid(uint16 x, uint16 y) public payable validCoordinates(x, y) validBid(x, y) onlyActivePixelWar {
        Pixel storage pixel = grid[x][y];
        if (pixel.owner != address(0)) {
            pendingWithdrawals[pixel.owner] += pixel.highestBid;
        }
        pixel.owner = msg.sender;
        pixel.highestBid = msg.value;

        emit PixelBid(x, y, msg.sender, msg.value);
    }

    function withdraw() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds to withdraw");
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function updateColor(uint16 x, uint16 y, uint8 red, uint8 green, uint8 blue)
        public
        validCoordinates(x, y)
        onlyPixelOwner(x, y)
        onlyActivePixelWar
    {
        if (!liteMode) {
            grid[x][y].r = red;
            grid[x][y].g = green;
            grid[x][y].b = blue;
        }
        emit ColorUpdated(x, y, red, green, blue);
    }

    function endPixelWar() public onlyOwner onlyActivePixelWar {
        pixelWarIsActive = false;

        for (uint16 x = 0; x < gridSize; x++) {
            for (uint16 y = 0; y < gridSize; y++) {
                Pixel storage pixel = grid[x][y];
                if (pixel.owner != address(0) && pixel.highestBid > 0) {
                    pendingWithdrawals[pixel.owner] += pixel.highestBid;
                }
            }
        }

        emit PixelWarEnded();
    }
}
