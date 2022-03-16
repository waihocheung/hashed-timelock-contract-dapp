const {assertEqualBN} = require("./helper/assert-equal-big-number");
const {newSecretHashPair} = require("./helper/new-secret-hash-pair");
const {isSha256Hash} = require("./helper/sha256");

const HashedTimeLockERC20 = artifacts.require("HashedTimeLockERC20");

function timelockOneHourInSeconds() {
  return Math.floor(Date.now() / 1000) + 3600;
}

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("HashedTimeLockERC20", function (accounts) {
  const sender = accounts[1];
  const receiver = accounts[2];

  const timeLock = timelockOneHourInSeconds();
  const oneEther = web3.utils.toWei(web3.utils.toBN(1), 'ether');
  const initDummySecret = '0x0000000000000000000000000000000000000000000000000000000000000000';

  it("newContract() should create new contract with correct details", async function () {
    // Arrange
    // Act
    // Assert
  });
});
