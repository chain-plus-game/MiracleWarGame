# MiracleAutoChessGame 
奇迹自走棋  
Dividend Token  

## 单位构成

基本结构：从NFT合约继承

卡牌类型对应(CardType Map)：

| TypeId       |  type  | comment  |
| :--------    | :------: | :--: |
| 1     | 单位(unit)   | 战斗单位(combat unit)  |
| 2     | 奇迹(miracle)   | 针对单位和棋盘效果的奇迹(Wonders for unit and board effects)  |
| 3     | 战略(strategy)   | 对于单位和棋盘效果的战略(Strategies for unit and board effects)  |


## 卡牌词缀 
Card entry map

### no.1 英勇 heroic  

单位效果 unit effect
1. 获得自身星级*2的攻击力  

奇迹效果 miracle effect  
1. 进行一次奇迹掷点，己方所有当前单位上升掷点数值的攻击力  

战略效果 strategy effect  
1. 己方所有单位的防御力上升攻击力数值

## 排名赛

在设置完自己的卡牌组合后，玩家可以挑战任意已经设置好卡牌组合的其他玩家。  

挑战者会支付自己的卡牌损耗，战斗结束后，被挑战者将获得挑战者卡牌损耗的1/3卡牌粉尘作为奖励。1/3的卡牌损耗将转入赛季奖池。  

挑战胜利，将获得被挑战者与自己积分之差一定比例的积分，挑战失败没有积分损耗。

积分将参与赛季排名，赛季结束时，将按照总体积分比例进行奖池分红。  

有关卡牌损耗相关，请参阅[ERC20代币MDT设计](./MiracleDust.md)  
