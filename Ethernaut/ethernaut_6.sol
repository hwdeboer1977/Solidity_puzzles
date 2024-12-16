// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Goal: claim ownership of the contract below
// Contract Delegation has already been deployed: get CA

// How to solve:
// 1. Get new instance from Delegation: CA = 0xFd6dB3dbEF3A4D346b13f4C04AeeaadCd781Aa24
// 2. Select Delegate contract in Remix and load contract via "at address"
// 3. Call the pwn function in Delegate contract

contract Delegate {
    address public owner;

    // Constructor sets the owner here
    constructor(address _owner) {
        owner = _owner;
    }

    // Public function so anyone can switch owner
    function pwn() public {
        owner = msg.sender;
    }
}

contract Delegation {
    address public owner;
    Delegate delegate;

    // Contract already deployed and ownership was set in constructor
    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    // Vulnerability here is this fallback function
    // If fallback function is called: it performs a delegatecall to the Delegate contract.
    // So delegatecall will execute the code in delegate contract
    // But it will update the state in Delegation!
    
    // How? 
    // The fallback() function in the Delegation contract is triggered when the contract receives
    // a call with data that does not match any of its existing function selectors.
    // For example: Delegation does not have a pwn() function.
    // Hacker can use msg.data = 0xdd365b8b (bytes4(keccak256("pwn()")) which is the function selector of pwn 
    // Since Delegation does not have a pwn() function, the fallback function is called. Within the fallback function:
    // delegatecall is executed, calling the Delegate.pwn() function.
    // The owner in the Delegation contract's storage is updated to the attacker’s address (msg.sender).
    fallback() external {
        (bool result,) = address(delegate).delegatecall(msg.data);
        if (result) {
            this;
        }
    }
}