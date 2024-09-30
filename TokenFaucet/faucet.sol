// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "../ERC20/erc20.sol";

contract faucet{
    uint256 public amountAllowed = 100;

    address public tokenContract;

    mapping(address => bool) public requestedAddress;

    event SendToken(address indexed Receiver, uint256 indexed Amount);

    constructor(address _tokenContract){
        tokenContract = _tokenContract;
    }

    function requestTokens() external{
        require(!requestedAddress[msg.sender],"Can't Request Multiple !");
        IERC20 token = IERC20(tokenContract);
        require(token.balanceOf(address(this)) >= amountAllowed,"Faucet Empty");

        token.transfer(msg.sender,amountAllowed);
        requestedAddress[msg.sender] = true;

        emit SendToken(msg.sender,amountAllowed);
    }
}