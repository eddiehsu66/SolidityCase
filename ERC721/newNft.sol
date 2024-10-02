// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./erc721.sol";

contract newNft is ERC721{
    uint public MAX_APES = 10000;

    constructor() ERC721("newNft", "newnft"){
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }
    
    function mint(address to, uint tokenId) external {
        require(tokenId >= 0 && tokenId < MAX_APES, "tokenId out of range");
        _mint(to, tokenId);
    }
}