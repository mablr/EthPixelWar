// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EthPixelWar {
    struct Pixel {
        address owner;
        uint256 highestBid;
        uint8 r;
        uint8 g;
        uint8 b;
    }

    address public owner;
    bool public pixelWarIsActive;
    uint256 public gridSize;
    mapping(uint256 => mapping(uint256 => Pixel)) public grid;
    mapping(address => uint256) pendingWithdrawals;

    event PixelBid(uint256 x, uint256 y, address bidder, uint256 bidAmount);
    event ColorUpdated(uint256 x, uint256 y, uint8 r, uint8 g, uint8 b);
    event PixelWarEnded();

    constructor(uint256 _gridSize) {
        owner = msg.sender;
        gridSize = _gridSize;
        pixelWarIsActive = true;
    }

    modifier validCoordinates(uint256 x, uint256 y) {
        require(x < gridSize && y < gridSize, "Invalid coordinates");
        _;
    }

    modifier onlyContractOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyActivePixelWar() {
        require(pixelWarIsActive, "The pixel war has ended");
        _;
    }

    modifier onlyPixelOwner(uint256 x, uint256 y) {
        require(msg.sender == grid[x][y].owner, "Not the pixel owner");
        _;
    }

    modifier validBid(uint256 x, uint256 y) {
        require(msg.value > grid[x][y].highestBid, "Bid must be higher than current highest bid");
        _;
    }

    function bid(uint256 x, uint256 y) public payable validCoordinates(x, y) validBid(x, y) onlyActivePixelWar {
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

    function updateColor(uint256 x, uint256 y, uint8 red, uint8 green, uint8 blue)
        public
        validCoordinates(x, y)
        onlyPixelOwner(x, y)
        onlyActivePixelWar
    {
        grid[x][y].r = red;
        grid[x][y].g = green;
        grid[x][y].b = blue;
        emit ColorUpdated(x, y, red, green, blue);
    }

    function endPixelWar() public onlyContractOwner onlyActivePixelWar {
        pixelWarIsActive = false;

        for (uint256 x = 0; x < gridSize; x++) {
            for (uint256 y = 0; y < gridSize; y++) {
                Pixel storage pixel = grid[x][y];
                if (pixel.owner != address(0) && pixel.highestBid > 0) {
                    pendingWithdrawals[pixel.owner] += pixel.highestBid;
                }
            }
        }

        emit PixelWarEnded();
    }

    function getPixel(uint256 x, uint256 y)
        public
        view
        validCoordinates(x, y)
        returns (address pixelOwner, uint256 pixelHighestBid, uint8 red, uint8 green, uint8 blue)
    {
        Pixel memory pixel = grid[x][y];
        return (pixel.owner, pixel.highestBid, pixel.r, pixel.g, pixel.b);
    }
}
