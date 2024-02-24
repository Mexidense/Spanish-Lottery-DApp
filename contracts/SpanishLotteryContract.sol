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
}

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
