// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// The function below also gives a return of 42 but it has way more opcodes than 10!!
// function whatIsTheMeaningOfLife() external pure returns(uint) {
//  return 42;
//}
// So use Assembly and create to deploy this contract with 10 opcodes

contract MagicNum {

    // public state variable that stores the address of the solver
    address public solver; 

    constructor() {}

    // This function sets the solver address. In the challenge, we need to  
    // find a way to set this solver address correctly so that it returns 42 when its whatIsTheMeaningOfLife() function is called.
    function setSolver(address _solver) public {
        solver = _solver;
    }

    /*  42 below
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
    */
}


interface IMagicNum {
    function solver() external view returns (address);
    function setSolver(address) external;
}

interface ISolver {
    function whatIsTheMeaningOfLife() external view returns (uint256);
}

contract Hack {

    // The Hack contract exploits the MagicNum contract and sets the solver address to a contract that will return the value 42.
    // Constructor takes an instance of IMagicNum (with its the target contract as input).
    constructor(IMagicNum target) {

        // We need to deploy a contract with Assembly
        // Opcode = create

        // bytecode is a hex string which represents the decimal 42
        // How? We have hex"69 602a60005260206000f3 600052600a6016f3"

        // This is a combination of (1) creation code and (2) runtime code
        // 1st: creation code = 69602a60005260206000f3

        // 69: This is the PUSH10 opcode, which means "push the next 10 bytes onto the stack."
        // PUSH1 42 = 602a (PUSH1 = 60 + 2a = 42)
        // PUSH1 0 = 6000 (PUSH1 = 60 + 00)
        // MSTORE = 52 
        // PUSH1 20 = 6020 
        // PUSH1 00 = 6000  
        // RETURN = F3
        // ====> 

        // 2nd: runtime code = 600052600a6016f3
        // Why?
        // 6000 - PUSH1 0 This pushes the number 0 onto the stack. This is a simple value that we are going to use later for memory operations.
        // 52 - MSTORE This instruction writes 0 to memory at position 0x00.
        // 60 0a: PUSH1 0x0a (or PUSH1 10). This pushes the value 0x0a (which is 10 in decimal) onto the stack.
        // 60 16: PUSH1 0x16 (or PUSH1 22). This pushes the value 0x16 (which is 22 in decimal) onto the stack.
        // F3: RETURN


        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        assembly {
            // create(value, offset, size)
            addr := create(0, add(bytecode, 0x20), 0x13)
        }
        require(addr != address(0));

        target.setSolver(addr);
    }
}
