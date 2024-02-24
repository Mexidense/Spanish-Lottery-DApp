// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./SpanishLotteryNft.sol";

contract SpanishLotteryTicketNft {    
    struct Owner {
        address ownerAddress;
        address smartContractAddress;
        address smartContractNftAddress;
        address smartContractLotteryTicketAddress;
    }

    Owner public owner;

    constructor(
        address _userAddress,
        address _smartContractAddress,
        address _smartContractNftAddress
    ) {
        owner = Owner(
            _userAddress,
            _smartContractAddress,
            _smartContractNftAddress,
            address(this)
        );
    }

    function mintTicket(address _owner, uint _ticketId) public {
        require(
            msg.sender == owner.smartContractAddress,
            "Smart contract lottery cannot create a lottery ticket"
        );

        SpanishLotteryNft(owner.smartContractNftAddress).safeMint(_owner, _ticketId);
    }
}