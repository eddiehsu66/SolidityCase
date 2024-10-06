// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract PaymentSplit{

    uint256 public totalShares;
    uint256 public totalReleased;

    mapping(address => uint256) public shares;
    mapping(address => uint256) public released; 
    address[] public payees;
    
    event PayeeAdded(address account, uint256 shares); 
    event PaymentReleased(address to, uint256 amount); 
    event PaymentReceived(address from, uint256 amount);

    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplitter: no payees");
        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    /**
     * @dev 回调函数，收到ETH释放PaymentReceived事件
     */
    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    /**
     * @dev 为有效受益人地址_account分帐，相应的ETH直接发送到受益人地址。任何人都可以触发这个函数，但钱会打给account地址。
     * 调用了releasable()函数。
     */
    function release(address payable _account) public virtual {
        require(shares[_account] > 0, "PaymentSplitter: account has no shares");
        uint256 payment = releasable(_account);
        require(payment != 0, "PaymentSplitter: account is not due payment");
        totalReleased += payment;
        released[_account] += payment;
        _account.transfer(payment);
        emit PaymentReleased(_account, payment);
    }

    /**
     * @dev 计算一个账户能够领取的eth。
     * 调用了pendingPayment()函数。
     */
    function releasable(address _account) public view returns (uint256) {
        uint256 totalReceived = address(this).balance + totalReleased;
        return pendingPayment(_account, totalReceived, released[_account]);
    }

    /**
     * @dev 根据受益人地址`_account`, 分账合约总收入`_totalReceived`和该地址已领取的钱`_alreadyReleased`，计算该受益人现在应分的`ETH`。
     */
    function pendingPayment(
        address _account,
        uint256 _totalReceived,
        uint256 _alreadyReleased
    ) public view returns (uint256) {
        return (_totalReceived * shares[_account]) / totalShares - _alreadyReleased;
    }

    /**
     * @dev 新增受益人_account以及对应的份额_accountShares。只能在构造器中被调用，不能修改。
     */
    function _addPayee(address _account, uint256 _accountShares) private {
        require(_account != address(0), "PaymentSplitter: account is the zero address");
        require(_accountShares > 0, "PaymentSplitter: shares are 0");
        require(shares[_account] == 0, "PaymentSplitter: account already has shares");
        payees.push(_account);
        shares[_account] = _accountShares;
        totalShares += _accountShares;
        emit PayeeAdded(_account, _accountShares);
    }
}