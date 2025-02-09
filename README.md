# EthPixelWar

EthPixelWar is a decentralized pixel art platform built on Ethereum where users can bid on pixels and create collaborative artwork. Each pixel can be owned by the highest bidder who can then set its color. When outbid, previous owners can withdraw their funds.

## Features

- Grid-based pixel art canvas (configurable size)
- Auction mechanism for pixel ownership
- RGB color customization for owned pixels
- Withdrawal system for outbid participants
- Owner-controlled war ending mechanism

## Smart Contract Overview

The main contract `EthPixelWar.sol` implements:
- Pixel ownership through bidding
- Color management for owned pixels
- Fund management for bids and withdrawals
- Access control for pixel modifications
- Event emission for frontend integration

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/EthPixelWar.git
cd EthPixelWar
```

2. Install dependencies:

```bash
forge install
```

## Deployment

1. Compile the contract:

```bash
forge build
```

2. Run the local node:

```bash
anvil
```

3. Deploy the contract:

```bash
forge script script/DeployEthPixelWar.s.sol --rpc-url http://localhost:8545 --broadcast
```

## Testing

```bash
forge test
```

## Web Interface

The web interface for EthPixelWar is available in a separate repository: [EthPixelWarUI](https://github.com/mablr/EthPixelWarUI)

Follow the instructions in the UI repository to set up and connect the frontend to your deployed contract.

## Contract Modes

### Standard Mode
- Full on-chain color storage
- Higher gas costs for color updates
- Complete decentralization

### Lite Mode
- Color data stored off-chain
- Lower gas costs
- Relies on event indexing for color state

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.