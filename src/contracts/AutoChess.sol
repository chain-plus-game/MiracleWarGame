// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../abstract/base.sol";
import "../abstract/easyRandom.sol";
import "../lib/AutoChessEntryFunc.sol";
import "../interface/GameAutoCheess.sol";
import "./MiracleCard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract GameAutoCheess is BaseGame, EasyRandom, IGameAutoCheess {
    using SafeMath for uint256;
    using AutoChessEntryFunc for AutoChessEntryFunc.EntryFunc;
    using AutoChessEntryFunc for AutoChessEntryFunc.fightData;
    using AutoChessEntryFunc for AutoChessEntryFunc.CardInstance;

    using EnumerableSet for EnumerableSet.UintSet;
    MiracleCard public cardNFT;
    AutoChessEntryFunc.EntryFunc private typeFunction;
    EnumerableSet.UintSet private _holderAddress;

    uint256 public cardGroupLength = 5;
    mapping(address => uint256[]) private _cardGroup;

    mapping(address => uint256) private _playerScore;

    constructor(address card) {
        cardNFT = MiracleCard(card);
        typeFunction.init();
    }

    function getPlayerScore(address _add) public view returns (uint256) {
        return _playerScore[_add];
    }

    function Authorize() public {
        _holderAddress.add(uint256(uint160(msg.sender)));
    }

    function setCardGroupLength(uint256 _length) public onlyOwner {
        cardGroupLength = _length;
    }

    function addressCardGroup(address _add)
        public
        view
        returns (uint256[] memory)
    {
        return _cardGroup[_add];
    }

    function setCardGroup(uint256[] memory group) public {
        require(group.length > cardGroupLength, "can not set group length");
        require(cardNFT.cardCanUse(msg.sender, group), "card can not use");
        _cardGroup[msg.sender] = group;
        emit updateCardGroup(msg.sender, group);
    }

    function getCardsStar(uint256[] memory cards)
        public
        view
        returns (uint256)
    {
        uint256 cardStar = 0;
        for (uint8 index = 0; index < cards.length; index++) {
            (, uint256 star, , , , , ) = cardNFT.getToken(cards[index]);
            cardStar += star;
        }
        return cardStar;
    }

    function challenge(address toCompetitor) public {
        uint256[] memory ownerCards = _cardGroup[msg.sender];
        require(ownerCards.length == 0, "card length max than 0");
        require(cardNFT.cardCanUse(msg.sender, ownerCards), "card can not use");
        require(
            _holderAddress.contains(uint256(uint160(toCompetitor))),
            "target does not exist"
        );
        uint256[] memory toCompetitorCards = _cardGroup[toCompetitor];
        if (toCompetitorCards.length == 0) {
            uint256 otherScore = _playerScore[toCompetitor];
            require(
                otherScore > 0,
                "You can't challenge someone who has no deck and no score"
            );
            uint256 sub = getCardsStar(ownerCards);
            (, uint256 newScore) = otherScore.trySub(sub);
            _playerScore[toCompetitor] = newScore;
            uint256 selfScore = _playerScore[msg.sender];
            (, uint256 newSelfScore) = selfScore.tryAdd(sub);
            _playerScore[msg.sender] = newSelfScore;
            emit battleOver(
                msg.sender,
                toCompetitor,
                sub,
                selfScore,
                sub,
                otherScore
            );
            return;
        }
        startBattle(ownerCards, toCompetitorCards, toCompetitor);
    }

    function startBattle(
        uint256[] memory ownerCards,
        uint256[] memory otherCards,
        address to
    ) private {
        // 创建对战数据
        AutoChessEntryFunc.CardInstance[]
            memory ownerCardInstaces = new AutoChessEntryFunc.CardInstance[](
                ownerCards.length
            );
        AutoChessEntryFunc.CardInstance[]
            memory otherCardInstaces = new AutoChessEntryFunc.CardInstance[](
                otherCards.length
            );
        for (uint256 index = 0; index < ownerCards.length; index++) {
            ownerCardInstaces[index] = createCardInstance(ownerCards[index]);
        }
        for (uint256 index = 0; index < otherCards.length; index++) {
            otherCardInstaces[index] = createCardInstance(otherCards[index]);
        }
        AutoChessEntryFunc.fightData memory fight = AutoChessEntryFunc
            .fightData({
                ownerCards: ownerCardInstaces,
                otherCards: otherCardInstaces
            });
        emit eventInitCardGroup(msg.sender, to, fight);
        fight.start(typeFunction);
    }

    function createCardInstance(uint256 cardId)
        private
        view
        returns (AutoChessEntryFunc.CardInstance memory)
    {
        (
            ,
            uint256 star,
            ,
            // 剩余粉尘
            uint256[] memory cardType,
            // 词条
            uint256[] memory cardEntrys,
            ,

        ) = cardNFT.getToken(cardId);
        uint256[] memory attributes = new uint256[](2);
        attributes[0] = 0;
        attributes[1] = 0;
        AutoChessEntryFunc.CardInstance memory instance = AutoChessEntryFunc
            .CardInstance({
                _id: cardId,
                _isEffects: false,
                _star: star,
                _cardTypes: cardType,
                _cardEntrys: cardEntrys,
                _cardAttributes: attributes // 0 攻击，1 生命
            });
        return instance;
    }
}
