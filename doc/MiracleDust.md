# 代币设计 
Token design  
[Code](/src/contracts/MiracleDust.sol)

## 目的
Purpose

奇迹粉尘的代币性质更多的类似与传统游戏中的金币，作为整个游戏生态基础货币使用。但我们希望游戏中的最终价值由卡牌NFT来决定，粉尘仅作为中间流通代币。这是与其他1155标准中使用的半同质化代币性质不同的。
  
The token properties of Miracle Dust are more similar to gold coins in traditional games, and are used as the base currency of the entire game ecology. But we hope that the final value in the game is anchored by the miracle card NFT, and the dust is only used as an intermediate circulation token. This is different from the semi-fungible tokens used in other 1155 standards.

## 流通量
Circulation  

粉尘代币的流通数量由卡牌NFT的数量与消耗决定，除了运营活动外，当玩家在使用卡牌NFT参与游戏时，卡牌NFT中的粉尘值将会损耗，一定比例的数值将会加到对应玩法的玩家账号，同时增加总流通量  

当卡牌NFT中的粉尘值小于一次使用消耗时，卡牌NFT将不能再参与游戏玩法，需要玩家使用粉尘代币对其进行充值，这会消耗代币的流通量  

  
The number of dust tokens in circulation is determined by the number and consumption of card NFTs. In addition to operational activities, when players use card NFTs to participate in games, the dust value in card NFTs will be depleted, and a certain percentage of the value will increase. to the player account corresponding to the gameplay, while increasing the total circulation

When the dust value in the card NFT is less than the consumption of one use, the card NFT will no longer be able to participate in the game play, and the player needs to use the dust token to recharge it, which will consume the circulation of the token

## 货币通缩和通胀
deflation and inflation  
  
代币的增发根据卡牌NFT的使用量而决定，当NFT与链游的使用量增加时，粉尘代币的流通量也会随着增加。为了维持货币的通胀速度，我们对每一份由卡牌NFT转入的粉尘代币进行1/3的销毁。  
  
The additional issuance of tokens is determined according to the usage of card NFTs. When the usage of NFTs and chain games increases, the circulation of dust tokens will also increase. In order to maintain the inflation rate of the currency, we burn 1/3 of each dust token transferred from the card NFT.  

## 上链

bsc test 0xEfEE4BaB67aBEc28F062cb7fCafD4CD9a09b26c3