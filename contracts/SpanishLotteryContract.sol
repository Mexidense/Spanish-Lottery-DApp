// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";
import "./SpanishLotteryTicketNft.sol";

contract SpanishLotteryContract is ERC20, Ownable {
    uint maxNumberOfTickets = 100000;
    address public spanishLotteryNftAddress;

    uint public ticketPrice = 5;
    mapping(address => uint[]) numberOfTicketsByPerson;
    mapping(uint => address) dnaTicket;
    uint randomOnce = 0;
    uint[] purchasedTickets;

    address public lotteryWinner;

    constructor() ERC20("SpanishLotteryContract", "SLC") {
        _mint(address(this), maxNumberOfTickets);
        spanishLotteryNftAddress = address(new SpanishLotteryNft());
    }

    mapping(address => address) public usersSmartContract;

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

    function registerUser() internal {
        address smartContractUser = address(
            new SpanishLotteryTicketNft(
                msg.sender,
                address(this),
                spanishLotteryNftAddress
            )
        );

        usersSmartContract[msg.sender] = smartContractUser;
    }

    function userInfo(address _account) public view returns (address) {
        return usersSmartContract[_account];
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        if (usersSmartContract[msg.sender] == address(0)) {
            registerUser();
        }

        uint256 cost = tokenPrice(_numberOfTokens);
        require(msg.value >= cost, "Insufficient token paid");

        uint256 totalAllowedTokens = balanceTokensSmartContract();
        require(
            _numberOfTokens <= totalAllowedTokens,
            "Smart contract lottery does not have this number of token to sell"
        );

        uint256 returnValue = msg.value - cost;
        payable(msg.sender).transfer(returnValue);

        _transfer(address(this), msg.sender, _numberOfTokens);
    }

    function backTokens(uint _numberOfTokens) public payable {
        require(_numberOfTokens > 0, "Required tokens must be greater than zero");
        require(_numberOfTokens <= balanceTokens(msg.sender), "Required tokens must be less than number of user's tokens");

        _transfer(msg.sender, address(this), _numberOfTokens);

        payable(msg.sender).transfer(tokenPrice(_numberOfTokens));
    }

    function buyTickets(uint _numberOfTickets) public {
        uint totalPrice = _numberOfTickets * ticketPrice;

        require(
            totalPrice <= balanceTokens(msg.sender),
            "User does not have enough token to buy tickets"
        );

        _transfer(msg.sender, address(this), totalPrice);

        for (uint i=0; i<_numberOfTickets; i++) {
            // Keep in mind: This does not guarantee that a purchased ticket number can be generated again
            uint randomTicketNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomOnce))) % maxNumberOfTickets;
            randomOnce++;

            numberOfTicketsByPerson[msg.sender].push(randomTicketNumber);
            purchasedTickets.push(randomTicketNumber);

            dnaTicket[randomTicketNumber] = msg.sender;

            SpanishLotteryTicketNft(usersSmartContract[msg.sender]).mintTicket(msg.sender, randomTicketNumber);
        }
    }

    function getTickets(address _owner) public view returns (uint[] memory) {
        return numberOfTicketsByPerson[_owner];
    }

    function generateWinner() public onlyOwner {
        uint numberOfPurchasedTickets = purchasedTickets.length;
        require(numberOfPurchasedTickets > 0, "No winner due no participants");
        
        uint randomIndex = uint(uint(keccak256(abi.encodePacked(block.timestamp))) % numberOfPurchasedTickets);
        uint chosenTicket = purchasedTickets[randomIndex];

        lotteryWinner = dnaTicket[chosenTicket];

        payable(lotteryWinner).transfer(address(this).balance * 95 / 100);
        payable(owner()).transfer(address(this).balance * 5 / 100);
    }
}
