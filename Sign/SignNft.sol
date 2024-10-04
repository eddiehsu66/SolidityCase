// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC721} from "../ERC721/erc721.sol";
import "./sign.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
contract SignatureNFT is ERC721,Sign{
    address immutable public signer;

    mapping(address =>bool) public mintedAddress;

    constructor(address _signer) ERC721("wtf","wtf"){
        signer = _signer;
    }

    function mint(address _account,uint256 _tokenId,bytes memory _signature) external {
        bytes32 _msgHash = getMessageHash(_account,_tokenId);
        bytes32 _ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(_msgHash);

        require(SignatureChecker.isValidSignatureNow(signer,_ethSignedMessageHash, _signature), "Invalid signature");
        require(!mintedAddress[_account], "Already minted!");
        _mint(_account, _tokenId);
        mintedAddress[_account] = true;
    }
}