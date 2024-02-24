// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";

contract SpanishLotteryContract is ERC20, Ownable {
    address public spanishLotteryNftAddress;

    constructor() ERC20("SpanishLotteryContract", "SLC") {
        _mint(address(this), 1000);
        spanishLotteryNftAddress = address(new SpanishLotteryNft());
    }

    address public lotteryWinner;

    mapping(address => address) public userSmartContract;

    function tokenPrice(uint256 _numberOfTokens) internal pure returns (uint256) {
        return _numberOfTokens * (1 ether);
    }

    function balanceTokens(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    function balanceTokensSmartContract() public view returns (uint256) {
        return balanceOf(address(this));
    }

    function balanceEthersSmartContract() public view returns (uint256) {
        return address(this).balance / 10**this.decimals();
    }

    function mint(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
    }
}

contract SpanishLotteryNft is ERC721 {
    constructor() ERC721("SpanishLotteryNFT", "SLN") {}
}
