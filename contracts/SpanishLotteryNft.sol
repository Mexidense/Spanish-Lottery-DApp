// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts@4.9.0/token/ERC721/ERC721.sol";
import "./SpanishLotteryContract.sol";

contract SpanishLotteryNft is ERC721 {
    address public smartContractAddress;

    constructor() ERC721("SpanishLotteryNFT", "SLN") {
        smartContractAddress = msg.sender;
    }

    function safeMint(address _owner, uint256 _ticketId) public {
        require(
            msg.sender == SpanishLotteryContract(smartContractAddress).userInfo(_owner),
            "Only owner smart contract can mint a NFT ticket"
        );

        _safeMint(_owner, _ticketId);
    }
}