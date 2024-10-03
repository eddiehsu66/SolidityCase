// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "../ERC721/erc721.sol";

contract DutchAuction is Ownable,ERC721{
    uint256 public constant COLLECTOIN_SIZE = 10000; // NFT总数
    uint256 public constant AUCTION_START_PRICE = 1 ether; // 起拍价(最高价)
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; // 结束价(最低价/地板价)
    uint256 public constant AUCTION_TIME = 10 minutes; // 拍卖时间，为了测试方便设为10分钟
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes; // 每过多久时间，价格衰减一次
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
        (AUCTION_TIME / AUCTION_DROP_INTERVAL); // 每次价格衰减步长
    
    uint256 public auctionStartTime; // 拍卖开始时间戳
    string private _baseTokenURI;   // metadata URI
    uint256[] private _allTokens; // 记录所有存在的tokenId 

    constructor() Ownable(msg.sender) ERC721("WTF", "WTF") {
        auctionStartTime = block.timestamp;
    }

    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    function getAuctionPrice() public view returns (uint256){
        if (block.timestamp < auctionStartTime){
            return AUCTION_START_PRICE;
        }else if (block.timestamp - auctionStartTime >= AUCTION_TIME){
            return AUCTION_END_PRICE;
        }else{
            uint256 steps = (block.timestamp - auctionStartTime)/ AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) public {
        _allTokens.push(tokenId);
    }

    function auctionMint(uint256 quantity) external payable {
        uint256 _saleStartTime = uint256(auctionStartTime);
        require(_saleStartTime != 0 && block.timestamp >= _saleStartTime,"sale has not started yet");
        require(totalSupply() + quantity <= COLLECTOIN_SIZE,"not enough remaing reserved for auction");

        uint256 totalCost = getAuctionPrice() * quantity;
        require(msg.value >= totalCost,"need to send more ETH;");

        for(uint256 i = 0;i<quantity;i++){
            uint256 mintIndex = totalSupply();
            _mint(msg.sender,mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }

        if (msg.value > totalCost){
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    function withdrawMoney() external onlyOwner{
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success,"withdraw failed;");
    }
    
}