// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Caller{
    address public proxy; // 代理合约地址

    constructor(address proxy_){
        proxy = proxy_;
    }

    // 通过代理合约调用increment()函数
    function increment() external returns(uint) {
        ( , bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));
        return abi.decode(data,(uint));
    }
    function getAbi() external pure returns(bytes memory){
        return abi.encodeWithSignature("increment()");
    }
}