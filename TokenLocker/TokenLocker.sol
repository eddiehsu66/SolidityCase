// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


contract TokenLocker{
    IERC20 public immutable token;
    // 受益人地址
    address public immutable beneficiary;
    // 锁仓时间(秒)
    uint256 public immutable lockTime;
    // 锁仓起始时间戳(秒)
    uint256 public immutable startTime;

    event TokenLockStart(address indexed beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary, address indexed token, uint256 releaseTime, uint256 amount);

    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 lockTime_
    ) {
        require(lockTime_ > 0, "TokenLock: lock time should greater than 0");
        token = token_;
        beneficiary = beneficiary_;
        lockTime = lockTime_;
        startTime = block.timestamp;

        emit TokenLockStart(beneficiary_, address(token_), block.timestamp, lockTime_);
    }

    /**
     * @dev 在锁仓时间过后，将代币释放给受益人。
     */
    function release() public {
        require(block.timestamp >= startTime+lockTime, "TokenLock: current time is before release time");

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");

        token.transfer(beneficiary, amount);

        emit Release(msg.sender, address(token), block.timestamp, amount);
    }

    function lockAmount() external view returns(uint256){
        uint256 amount = token.balanceOf(address(this));
        return amount;
    }
}