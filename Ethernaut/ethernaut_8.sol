// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    bool public locked;
    bytes32 private password;

    // Goal: unlock the vault
    // Contract has already been deployed: get CA
    // Password is set to private so we cant manipulate it here
    // But password is saved somewhere in storage at the blockchain.
    // Use await web3.eth.getStorageAt(contract.address, xxx) in developer tools Chrome
    // Slot 0 is the boolean
    // Slot 1 is the password:  await web3.eth.getStorageAt(contract.address, 1) 
    // = 0x412076657279207374726f6e67207365637265742070617373776f7264203a29

    constructor(bytes32 _password) {
        locked = true;
        password = _password;
    }

    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}