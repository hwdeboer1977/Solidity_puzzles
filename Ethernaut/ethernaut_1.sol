// SPDX-License-Identifier: MIT
// This license allows others to use, modify, and distribute the code as long as they provide the same license terms.
pragma solidity ^0.8.0; // Specifies the Solidity version for the compiler.

contract Fallback {
    // Mapping to store contributions made by each address.
    mapping(address => uint256) public contributions;

    // Address of the contract's owner.
    address public owner;

    // Constructor: executed when the contract is deployed.
    // Sets the deployer of the contract as the owner and assigns an initial contribution.
    constructor() {
        owner = msg.sender; // Assign the deployer's address as the owner.
        contributions[msg.sender] = 1000 * (1 ether); // Give the owner an initial contribution balance.
    }

    // Modifier to restrict certain functions to the contract owner only.
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner"); // Ensure the caller is the owner.
        _; // Continue execution of the modified function.
    }

    // Function to allow users to contribute small amounts of Ether to the contract.
    function contribute() public payable {
        require(msg.value < 0.001 ether, "Contribution exceeds limit"); // Restrict contribution to less than 0.001 Ether.
        contributions[msg.sender] += msg.value; // Update the caller's contribution balance.

        // If the caller's contributions exceed the current owner's, they become the new owner.
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    // Function to check the contribution balance of the caller.
    function getContribution() public view returns (uint256) {
        return contributions[msg.sender]; // Return the contribution balance of the message sender.
    }

    // Function to withdraw all Ether from the contract. Only the owner can call this.
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance); // Transfer the entire contract balance to the owner.
    }

    // Receive function: executed when the contract receives Ether without data.
    receive() external payable {
        require(msg.value > 0, "Must send Ether"); // Ensure Ether is sent with the transaction.
        require(contributions[msg.sender] > 0, "No contributions from sender"); // Ensure the sender has contributed previously.
        
        // Update the owner to the sender if these conditions are met.
        owner = msg.sender;
    }
}
