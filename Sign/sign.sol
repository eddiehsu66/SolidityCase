// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Sign{
    function getMessageHash(address _account,uint256 _tokenId) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_account,_tokenId));
    }

    function toEthSighedMessageHash(bytes32 hash) public pure returns (bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    // @dev 从_msgHash和签名_signature中恢复signer地址
    function recoverSigner(bytes32 _msgHash, bytes memory _signature) internal pure returns (address){
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        // 使用ecrecover(全局函数)：利用 msgHash 和 r,s,v 恢复 signer 地址
        return ecrecover(_msgHash, v, r, s);
    }

    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) public pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

}