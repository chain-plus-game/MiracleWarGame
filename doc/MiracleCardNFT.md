# NFT卡牌设计  
NFT card design

相关链接  
Related Links
-------------
>https://eips.ethereum.org/EIPS/eip-1155  
>https://github.com/ethereum/EIPs/issues/1155  
>https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC1155  
>https://eips.ethereum.org/EIPS/eip-1155  
>https://docs.openzeppelin.com/contracts/3.x/erc1155  

## 链上数据与元数据
On-chain data and metadata  

在标准1155协议实现中，由于合约存储昂贵的原因，链上通过跟踪token id和相关远程uri来实现保存大对象，这种方式避开了链上存储昂贵的问题，但也带来了外部数据不可控性。在游戏中，经常会遇到运气成分在内的活动，这种‘凭运气’的数据形式通常被传统游戏厂商通过暗箱来控制利润。
所以，我们对历史方案做了折中考量，将部分随机性数据存储在链上，将部分确定性数据放在元数据中。  

In the implementation of the standard 1155 protocol, due to the high cost of contract storage, large objects are saved on the chain by tracking the token id and related remote URIs. This method avoids the problem of expensive on-chain storage, but also brings external data. uncontrollability. In games, activities involving luck are often encountered, and this form of 'luck' data is usually used by traditional game manufacturers to control profits through a black box.
Therefore, we made a compromise on the historical scheme, storing some random data on the chain, and putting some deterministic data in the metadata.  

### 链上数据结构
On-chain data structure

| name         |    type  | comment  |
| :--------    | :------: | :--: |
| _tokenId     | string   | id   |
| _star        |   int    | star quality  |
| _tokenVal    |   int    | The amount of MDT remaining in the card  |
| _cardType    | int array| The type id to which the card belongs, and the specific attributes are defined according to the game|
| _cardEntrys  | int array| Attribute entry in the card, the specific role is defined by the game|
| _uri         | string   | metadata uri|
| _ownerAddress| address  | owner address|  
  

### 元数据
metadata
  
1155协议标准json结构,发布到ipfs网络  
1155 protocol standard json structure, published to ipfs network
