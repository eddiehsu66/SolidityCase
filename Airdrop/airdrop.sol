// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "../ERC20/erc20.sol";

contract Airdrop{

    mapping (address => uint256) public failTransferList;

    mapping (address => uint256) public successTransferList;
    constructor() payable {}

    function multiTransferToken(address _token,address[] calldata _addresses,uint256[] calldata _amounts) external {
        require(_addresses.length == _amounts.length,"address and amounts not equal");
        IERC20 token = IERC20(_token);
        uint _amountSum = 0;

        for (uint i = 0;i<_amounts.length;i++){
            _amountSum = _amountSum + _amounts[i];
        }

        require(token.allowance(msg.sender,address(this))>= _amountSum,"airdrop tokken not enough");

        for(uint8 i;i<_addresses.length;i++){
            token.transferFrom(msg.sender,_addresses[i],_amounts[i]);
        }
    }

    function multiTransferETH(address[] calldata _addresses,uint256[] calldata _amounts) public payable {
        require(_addresses.length == _amounts.length,"address and amounts not equal");
        uint _amountSum = 0;

        for (uint i = 0;i<_amounts.length;i++){
            _amountSum = _amountSum + _amounts[i];
        }
        require(msg.value>= _amountSum,"eth not enough");

        for(uint i = 0;i<_addresses.length;i++){
            (bool success,) = _addresses[i].call{value:_amounts[i] * 1 ether}("");
            if (!success){
                failTransferList[_addresses[i]] = _amounts[i];
            } else{
                successTransferList[_addresses[i]] = _amounts[i];
            }
        }

    }
}