# Lottery - DApp

Decentralized application (DApp) to manage a Spanish lottery system using ERC20 & ERC721 tokens.

```mermaid
mindmap
  root((SpanishLottery SmartContract))
    id))User SmartContract((
        id))User NFT SmartContract((
            id))User NFT Ticket SmartContract((
    id[SmartLottery NFT SmartContract]
      id[SmartLottery NFT Ticket SmartContract]
```

## Use cases
This DApp has the following use cases:

- Deploy a Spanish Lottery Smart Contract.
- Buy Spanish Lottery tokens.
- Returns Spanish Lottery tokens.
- Buy Spanish Lottery NFT tickets.
- Generate a winner.


### Deploy a Spanish Lottery Smart Contract

```mermaid
sequenceDiagram
    DeploymentSystem->>+SpanishLotteryContract: Deploy Lottery contract with 100k tickets
    Note right of DeploymentSystem: [ERC-20] Name: SpanishLotteryContract, Symbol: SLC

    SpanishLotteryContract->>SpanishLotteryNft: Create a NFT Lottery contract
    Note right of SpanishLotteryNft: [ERC-721] Name: SpanishLotteryNFT, Symbol: SLN

    SpanishLotteryContract-->>-DeploymentSystem: Deployed!
```
### Buy Spanish Lottery tokens [ERC-20]
```mermaid
sequenceDiagram
    User->>SpanishLottery(ContractAddress): Buy some tokens
        opt msg.value < token cost
            SpanishLottery(ContractAddress)->>User: Insufficient token paid
        end
        opt Is a new user?
            SpanishLottery(ContractAddress)->>SpanishLotteryTicketNft: Create NFT ticket contract
            SpanishLottery(ContractAddress)->>SpanishLottery(ContractAddress): Register user on Lottery contract
            Note right of SpanishLottery(ContractAddress): This create a NFT ticket address gatthering address for this user on lottery smart contract address
        end
        opt Do tokens exceed all Lottery contract tokens has?
            SpanishLottery(ContractAddress)->>User: Smart contract lottery does not have this number of token to sell
        end
        SpanishLottery(ContractAddress)->>User: Pay back remain tokens from token cost
        SpanishLottery(ContractAddress)->>SpanishLottery(UserAddress): Transfer tokens
```

### Returns Spanish Lottery tokens [ERC-20]
```mermaid
sequenceDiagram
    User->>SpanishLottery(ContractAddress): Return some tokens
        opt msg.value < 0
            SpanishLottery(ContractAddress)->>User: Required tokens must be greater than zero
        end
        opt msg.value > userBalanceTokens
            SpanishLottery(ContractAddress)->>User: Required tokens must be less or equals than number of user's tokens
        end
        SpanishLottery(UserAddress)->>SpanishLottery(ContractAddress): Returns tokens
        SpanishLottery(ContractAddress)->>User: Transfer tokens
```

### Buy Spanish Lottery NFT tickets [ERC-721]
```mermaid
sequenceDiagram
    User->>SpanishLottery(ContractAddress): Buy X tickets
        opt totalPriceForTickets > userTokenBalance
            SpanishLottery(ContractAddress)->>User: User does not have enough token to buy tickets
        end
        SpanishLottery(UserAddress)->>SpanishLottery(ContractAddress): Transfer token price
        SpanishLottery(ContractAddress)->>SpanishLottery(ContractAddress): Generate X random tickets
        SpanishLottery(ContractAddress)->>SpanishLottery(ContractAddress): Store all tickets for this UserAddress 
    
        SpanishLottery(ContractAddress)->>SpanishLotteryNFT(UserAddress): Mint every ticket as a new NFT
```

### Generate a winner [ERC-20]
```mermaid
sequenceDiagram
    OwnerContractAddress->>SpanishLottery(ContractAddress): Generate a winner!
        opt purchasedTicket = 0
            SpanishLottery(ContractAddress)->>OwnerContractAddress: No winner due no participants
        end
        SpanishLottery(ContractAddress)->>SpanishLottery(ContractAddress): Select a ticket to award
        SpanishLottery(ContractAddress)->>SpanishLottery(ContractAddress): Get the winner user address for this selected ticket
        SpanishLottery(ContractAddress)->>UserAddress: Transfer award to user address (95% total contract balance)
        SpanishLottery(ContractAddress)->>OwnerContractAddress: Transfer lottery benefit to owner contract address (5% total contract balance)
```

> [!NOTE]
> All resources come from this [Udemy course](https://www.udemy.com/course/bootcamp-blockchain-cero-experto), specially 16th section: Lottery using ERC-20 & ERC-721 by [Joan Amengual](https://github.com/joaneeet7).
