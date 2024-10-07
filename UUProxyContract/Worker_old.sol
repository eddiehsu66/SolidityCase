// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Worker{
    address public implementation; // 与Proxy保持一致，防止插槽冲突
    address public admin; 
    uint public x = 99; 
    event CallSuccess(); // 调用成功事件

    // 这个函数会释放CallSuccess事件并返回一个uint。
    // 函数selector: 0xd09de08a
    function increment() external returns(uint) {
        emit CallSuccess();
        x = x +1;
        return x;
    }
    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}