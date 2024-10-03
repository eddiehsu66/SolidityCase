// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import {ERC721} from "../ERC721/erc721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";  

contract MerkleTree is ERC721{
    bytes32 immutable public root;
    mapping(address => bool) public mintedAddress;

    constructor(bytes32 merkleroot) ERC721("wtf","wtf"){
        root = merkleroot;
    }

    function mint(uint256 tokenId,bytes32[] calldata proof) external{
        require(_verify(_leaf(msg.sender),proof),"Invalid merkle proof");
        require(!mintedAddress[msg.sender],"Already minted");
        _mint(msg.sender,tokenId);
        mintedAddress[msg.sender] = true;
    }

    function _leaf(address account) internal pure returns(bytes32){
        return keccak256(abi.encodePacked(account));
    }
    function _verify(bytes32 leaf,bytes32[] memory proof)internal view returns(bool){
        return MerkleProof.verify(proof,root,leaf);
    }
}