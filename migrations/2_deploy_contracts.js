const HashedTimelockETH = artifacts.require('./HashedTimelockETH.sol')
const HashedTimeLockERC20 = artifacts.require('./HashedTimeLockERC20.sol')

module.exports = function (deployer) {
  deployer.deploy(HashedTimelockETH),
  deployer.deploy(HashedTimeLockERC20)
}