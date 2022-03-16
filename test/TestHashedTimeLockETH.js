const {assertEqualBN} = require("./helper/assert-equal-big-number");
const {newSecretHashPair} = require("./helper/new-secret-hash-pair");
const {isSha256Hash} = require("./helper/sha256");

const HashedTimeLockETH = artifacts.require("HashedTimeLockETH");

function timelockOneHourInSeconds() {
  return Math.floor(Date.now() / 1000) + 3600;
}

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("HashedTimeLockETH", function (accounts) {
  const sender = accounts[1];
  const receiver = accounts[2];

  const timeLock = timelockOneHourInSeconds();
  const oneEther = web3.utils.toWei(web3.utils.toBN(1), 'ether');
  const initDummySecret = '0x0000000000000000000000000000000000000000000000000000000000000000';

  it('newContract() should create new contract with correct details', async () => {
    // Arrage
    const hashPair = newSecretHashPair();
    const htlcContract = await HashedTimeLockETH.deployed();

    // Act
    const txReceipt = await htlcContract.createContract(
      receiver,
      hashPair.hash,
      timeLock,
      {
        from: sender,
        value: oneEther,
      }
    );

    // Assert
    const logArgs = txReceipt.logs[0].args;
    const contractId = logArgs.contractId;

    assert(isSha256Hash(contractId))
    assert.equal(logArgs.sender, sender);
    assert.equal(logArgs.receiver, receiver);
    assertEqualBN(logArgs.amount, oneEther);
    assert.equal(logArgs.hashlock, hashPair.hash);
    assert.equal(logArgs.timelock, timeLock);

    // Act
    const contractArr = await htlcContract.getContract.call(contractId);

    // Assert
    const contract = htlcArrayToObj(contractArr);
    assert.equal(contract.sender, sender);
    assert.equal(contract.receiver, receiver);
    assertEqualBN(contract.amount, oneEther);
    assert.equal(contract.hashlock, hashPair.hash);
    assert.equal(contract.timelock.toNumber(), timeLock);
    assert.isFalse(contract.withdrawn);
    assert.isFalse(contract.refunded);
    assert.equal(contract.secret, initDummySecret);
  })

  it('withdraw() should send receiver funds when given the correct secret', async () => {
    // todo: add test logic

    // Arrange
    // Act
    // Assert
  })

  it('refund() should be allowed after timelock expires', async () => {
    // todo: add test logic

    // Arrange
    // Act
    // Assert
  })

  it('refund() should not be allowed before timelock expires', async () => {
    // todo: add test logic

    // Arrange
    // Act
    // Assert
  })
});
