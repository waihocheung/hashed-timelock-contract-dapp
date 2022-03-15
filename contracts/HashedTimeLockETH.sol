// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


contract HashedTimeLockETH {


    event HTLCCreate(
        bytes32 indexed contractId,
        address indexed sender,
        address indexed receiver,
        uint amount,
        bytes32 hashlock,
        uint timelock
    );
    event HTLCWithdraw(bytes32 indexed contractId);
    event HTLCRefund(bytes32 indexed contractId);

    struct ContractDetails {
        address payable sender;
        address payable receiver;
        uint amount;
        bytes32 hashlock;
        uint timelock;
        bool withdrawn;
        bool refunded;
        bytes32 preimage;
    }

    modifier validFunds() {
        require(msg.value > 0, "msg.value must be > 0");
        _;
    }
    modifier futureTimelock(uint _time) {
        require(_time > block.timestamp, "timelock time must be in the future");
        _;
    }
    modifier contractExists(bytes32 _contractId) {
        require(haveContract(_contractId), "contractId does not exist");
        _;
    }
    modifier hashlockMatches(bytes32 _contractId, bytes32 _x) {
        require(
            contracts[_contractId].hashlock == sha256(abi.encodePacked(_x)),
            "hashlock hash does not match"
        );
        _;
    }
    modifier withdrawable(bytes32 _contractId) {
        require(contracts[_contractId].receiver == msg.sender, "Not withdrawable: not receiver");
        require(contracts[_contractId].withdrawn == false, "Not withdrawable: already withdrawn");
        require(contracts[_contractId].timelock > block.timestamp, "Not withdrawable: timelock time has passed");
        _;
    }
    modifier refundable(bytes32 _contractId) {
        require(contracts[_contractId].sender == msg.sender, "Not refundable: not sender");
        require(contracts[_contractId].refunded == false, "Not refundable: already refunded");
        require(contracts[_contractId].withdrawn == false, "Not refundable: already withdrawn");
        require(contracts[_contractId].timelock <= block.timestamp, "Not refundable: timelock time not yet passed");
        _;
    }

    mapping (bytes32 => ContractDetails) contracts;

    /**
     * Sender sets up a new hash time lock contract depositing the ETH and
     * providing the reciever lock terms.
     *
     * @param _receiver Receiver of the ETH.
     * @param _hashlock A sha-2 sha256 hash hashlock.
     * @param _timelock UNIX epoch seconds time that the lock expires at.
     *                  Refunds can be made after this time.
     * @return contractId Id of the new HTLC. This is needed for subsequent
     *                    calls.
     */
    function createContract(address payable _receiver, bytes32 _hashlock, uint _timelock)
        external
        payable
        validFunds
        futureTimelock(_timelock)
        returns (bytes32 contractId)
    {
        contractId = sha256(
            abi.encodePacked(
                msg.sender,
                _receiver,
                msg.value,
                _hashlock,
                _timelock
            )
        );

        if (haveContract(contractId))
            revert("Contract already exists");

        contracts[contractId] = ContractDetails(
            payable(msg.sender),
            _receiver,
            msg.value,
            _hashlock,
            _timelock,
            false,
            false,
            0x0
        );

        emit HTLCCreate(
            contractId,
            msg.sender,
            _receiver,
            msg.value,
            _hashlock,
            _timelock
        );
    }

    /**
     * Called by the receiver once they know the preimage of the hashlock.
     * This will transfer the locked funds to their address.
     *
     * @param _contractId Id of the HTLC.
     * @param _preimage sha256(_preimage) should equal the contract hashlock.
     * @return bool true on success
     */
    function withdraw(bytes32 _contractId, bytes32 _preimage)
        external
        contractExists(_contractId)
        hashlockMatches(_contractId, _preimage)
        withdrawable(_contractId)
        returns (bool)
    {
        ContractDetails storage c = contracts[_contractId];
        c.preimage = _preimage;
        c.withdrawn = true;
        c.receiver.transfer(c.amount);
        emit HTLCWithdraw(_contractId);
        return true;
    }

    /**
     * Called by the sender if there was no withdraw AND the time lock has
     * expired. This will refund the contract amount.
     *
     * @param _contractId Id of HTLC to refund from.
     * @return bool true on success
     */
    function refund(bytes32 _contractId)
        external
        contractExists(_contractId)
        refundable(_contractId)
        returns (bool)
    {
        ContractDetails storage c = contracts[_contractId];
        c.refunded = true;
        c.sender.transfer(c.amount);
        emit HTLCRefund(_contractId);
        return true;
    }

    /**
     * Get contract details.
     * @param _contractId HTLC contract id
     * @return All parameters in struct ContractDetails for _contractId HTLC
     */
    function getContract(bytes32 _contractId)
        public
        view
        returns (ContractDetails memory)
    {
        if (!haveContract(_contractId))
            return ContractDetails(payable(address(0)), payable(address(0)), 0, 0, 0, false, false, 0);

        ContractDetails storage c = contracts[_contractId];
        return ContractDetails(
            c.sender,
            c.receiver,
            c.amount,
            c.hashlock,
            c.timelock,
            c.withdrawn,
            c.refunded,
            c.preimage
        );
    }

    /** 
    * Check if a contract with a specific contract id exists
    * @param _contractId HTLC contract id
    */
    function haveContract(bytes32 _contractId)
        internal
        view
        returns (bool exists)
    {
        exists = (contracts[_contractId].sender != address(0));
    }
}
