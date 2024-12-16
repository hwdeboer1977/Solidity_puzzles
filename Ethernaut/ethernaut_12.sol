// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Privacy {
    bool public locked = true;
    uint256 public ID = block.timestamp;
    uint8 private flattening = 10;
    uint8 private denomination = 255;
    uint16 private awkwardness = uint16(block.timestamp);
    bytes32[3] private data;

    // Goal: unlock contract

    // Constructor's input: array of three bytes32 values
    constructor(bytes32[3] memory _data) {
        data = _data;
    }

    // We can unlock if we provide _key that equals bytes16(data[2])
    // We need to third element of data: data[2]
    // data is private but stored on the blockchain
    // variable true (bool) = slot 0 (1 byte)
    // variable ID (unint256) = slot 1 (32 bytes)
    // variable flattening (uint8) = slot 2 (8 bytes)
    // variable denomination (uint8) = slot 2 (8 bytes)
    // variable awkwardness (unint16) = slot 2 (16 bytes) and slot 2 full
    // 1st element in data: data[0] = slot 3 (32 bytes)
    // 2nd element in data: data[1] = slot 4 (32 bytes)
    // 3rd element in data: data[2] = slot 5 (32 bytes) ==> we need slot 5!!

    // Get contract address
    // Use await web3.eth.getStorageAt(contract.address, 5)
    // 0xca2a8c908fe2200e04c07d28aeb0ff42642df5b238080f1665d2b976eed2329b = 32-byte (256-bit) hexadecimal value.
    // In hexadecimal notation: 1 byte is represented by 2 characters, so a 32-byte value translates to 64 characters (after 0x).
    // We need to first 32 characters, or 16 bytes after 0x!
    // use addr.slice(0,34) = 0xca2a8c908fe2200e04c07d28aeb0ff42
    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));
        locked = false;
    }

    /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
    */
}