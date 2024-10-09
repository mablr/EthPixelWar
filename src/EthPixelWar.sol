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

    uint public gridSize;
    mapping(uint => mapping(uint => Pixel)) public grid;
    mapping(address => uint256) pendingWithdrawals;

    event PixelBid(uint x, uint y, address bidder, uint256 bidAmount);
    event ColorUpdated(uint x, uint y, uint8 r, uint8 g, uint8 b);

    constructor(uint _gridSize) {
        gridSize = _gridSize;
    }

    modifier validCoordinates(uint x, uint y) {
        require(x < gridSize && y < gridSize, "Invalid coordinates");
        _;
    }

    modifier onlyOwner(uint x, uint y) {
        require(msg.sender == grid[x][y].owner, "Not the pixel owner");
        _;
    }

    modifier validBid(uint x, uint y) {
        require(msg.value > grid[x][y].highestBid, "Bid must be higher than current highest bid");
        _;
    }


    function bid(uint x, uint y) public payable validCoordinates(x, y) validBid(x, y) {
        Pixel storage pixel = grid[x][y];
        if (pixel.owner != address(0)) {
            pendingWithdrawals[pixel.owner] += pixel.highestBid;
        }
        pixel.owner = msg.sender;
        pixel.highestBid = msg.value;

        emit PixelBid(x, y, msg.sender, msg.value);
    }

    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds to withdraw");
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function updateColor(uint x, uint y, uint8 red, uint8 green, uint8 blue) public validCoordinates(x, y) onlyOwner(x, y) {
        grid[x][y].r = red;
        grid[x][y].g = green;
        grid[x][y].b = blue;
        emit ColorUpdated(x, y, red, green, blue);
    }

    function getPixel(uint x, uint y) public view validCoordinates(x, y) returns (address owner, uint256 highestBid, uint8 red, uint8 green, uint8 blue) {
        Pixel memory pixel = grid[x][y];
        return (pixel.owner, pixel.highestBid, pixel.r, pixel.g, pixel.b);
    }

}
