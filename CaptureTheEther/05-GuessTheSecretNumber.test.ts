import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils } = ethers;

describe('GuessTheSecretNumberChallenge', () => {
  let target: Contract;
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('GuessTheSecretNumberChallenge', deployer)
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
    // Solidity contract takes the keccak256 of the answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;
    const answerHash = '0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365';
    let foundGuess = null;

    // keccak256 function is a cryptographic hash function, so one-way
    // We need to guess and unit is [0,255]
    // Iterate through all possible uint8 values (0-255)
    for (let n = 0; n <= 255; n++) {
      // Compute the keccak256 hash
      const guessHash = ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(['uint8'], [n]));

      // Check if the hash matches the target hash
      if (guessHash === answerHash) {
        foundGuess = n;
        console.log(`Found correct guess: ${foundGuess}`);
        break;
      }
    }

    // Ensure we found a guess
    if (foundGuess === null) {
      console.error('No matching guess found.');
      return;
    }

    // Make the guess
    await target.guess(foundGuess, {
      value: ethers.utils.parseEther('1'),
    });

    expect(await target.isComplete()).to.equal(true);
  });
});
