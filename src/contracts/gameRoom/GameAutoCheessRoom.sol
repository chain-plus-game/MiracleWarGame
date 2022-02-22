// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../../abstract/easyRandom.sol";
import "../../lib/AutoChessEntryFunc.sol";
import "../../interface/IGameAutoCheessRoom.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract GameAutoCheessRoom is EasyRandom, IGameAutoCheessRoom {
    using SafeMath for uint256;
    using AutoChessEntryFunc for AutoChessEntryFunc.EntryFunc;
    using AutoChessEntryFunc for AutoChessEntryFunc.CardInstance;
    using AutoChessEntryFunc for AutoChessEntryFunc.fightData;

    using EnumerableSet for EnumerableSet.UintSet;

    AutoChessEntryFunc.EntryFunc private _funcMap;
    EnumerableSet.UintSet private _holderAddress;

    constructor() {
        _funcMap.addHander(1, heroic);
        _funcMap.addHander(2, charge);
        _funcMap.addHander(3, heroic);
        _funcMap.addHander(4, heroic);
        _funcMap.addHander(5, heroic);
    }

    function initCardGroup(
        AutoChessEntryFunc.CardInstance[] memory ownerCards,
        AutoChessEntryFunc.CardInstance[] memory otherCards
    ) private {
        for (uint256 index = 0; index < ownerCards.length; index++) {
            for (
                uint256 entryIndex = 0;
                entryIndex < ownerCards[index]._cardEntrys.length;
                entryIndex++
            ) {
                uint256 entryId = ownerCards[index]._cardEntrys[entryIndex];
                _funcMap.dispatch(
                    index,
                    entryId,
                    0,
                    AutoChessEntryFunc.stage.init,
                    ownerCards,
                    otherCards,
                    0
                );
            }
        }
    }

    function start(AutoChessEntryFunc.fightData memory _fight)
        public
        returns (uint8)
    {
        // init->第一轮效果->第二轮效果
        // 过一遍init
        initCardGroup(_fight.ownerCards, _fight.otherCards);
        emit initCardGroupStart(0, _fight.ownerCards);
        initCardGroup(_fight.otherCards, _fight.ownerCards);
        emit initCardGroupStart(1, _fight.otherCards);
        GameState winner = GameState.running;
        uint8 roundNum = 1;
        while (true) {
            winner = clickOver(_fight);
            if (winner != GameState.running) {
                break;
            }
            _funcMap.doFighting(_fight.otherCards, _fight.ownerCards);
            winner = clickOver(_fight);
            if (winner != GameState.running) {
                break;
            }
            _funcMap.doFighting(_fight.ownerCards, _fight.otherCards);
            roundNum += 1;
            emit eventRoundEnds(roundNum, _fight.ownerCards, _fight.otherCards);
        }
        if (winner == GameState.ownerWiner) {
            return 0;
        }
        if (winner == GameState.targetWiner) {
            return 1;
        }
        return 2;
    }

    function clickOver(AutoChessEntryFunc.fightData memory _fight)
        internal
        pure
        returns (GameState)
    {
        bool ownerDel = true;
        for (uint256 index = 0; index < _fight.ownerCards.length; index++) {
            if (
                _fight.ownerCards[index]._cardTypes[0] == 1 &&
                _fight.ownerCards[index]._cardAttributes[1] > 0
            ) {
                ownerDel = false;
            }
        }
        bool otherDel = true;
        for (uint256 index = 0; index < _fight.otherCards.length; index++) {
            if (
                _fight.otherCards[index]._cardTypes[0] == 1 &&
                _fight.otherCards[index]._cardAttributes[1] > 0
            ) {
                otherDel = false;
            }
        }
        if (ownerDel && !otherDel) {
            return GameState.targetWiner;
        }
        if (!ownerDel && otherDel) {
            return GameState.ownerWiner;
        }
        return GameState.running;
    }

    function crush(
        uint256 cardIndex,
        uint256 otherCardIndex,
        AutoChessEntryFunc.stage pipType,
        AutoChessEntryFunc.CardInstance[] memory ownerCards,
        AutoChessEntryFunc.CardInstance[] memory otherCards,
        uint256 harm
    ) private {
        uint256 cardTypesId = ownerCards[cardIndex]._cardTypes[0];
        if (cardTypesId == 1 && pipType == AutoChessEntryFunc.stage.init) {
            ownerCards[cardIndex]._cardAttributes[0] +=
                ownerCards[cardIndex]._star *
                1;
            ownerCards[cardIndex]._cardAttributes[1] += ownerCards[cardIndex]
                ._star;
            return;
        }
        if (cardTypesId == 1 && pipType == AutoChessEntryFunc.stage.fighting1) {
            // 击破一个敌方单位时进行一次掷点，对下一个攻击单位造成点数伤害
            if (otherCards[otherCardIndex]._cardAttributes[1] > harm) return;
            if (otherCardIndex == (otherCards.length - 1)) return;
            for (
                uint256 index = otherCardIndex + 1;
                index < otherCards.length;
                index++
            ) {
                if (otherCards[index]._cardTypes[0] == 1) {
                    uint256 rand = random(6);
                    ownerCards[cardIndex]._cardAttributes[0] = rand;
                    _funcMap.doFightingTo(
                        cardIndex,
                        index,
                        ownerCards,
                        otherCards,
                        AutoChessEntryFunc.stage.effect
                    );
                }
            }
            return;
        }
        if (cardTypesId == 2 && pipType == AutoChessEntryFunc.stage.fighting1) {
            // 摧毁对方一张星级不高于造成掷点点数+卡牌星级的奇迹卡或战略卡
            uint256 rand = random(6);
            for (uint8 index = 0; index < otherCards.length; index++) {
                if (otherCards[index]._cardTypes[0] == 1) continue;
                if (otherCards[index]._star > (rand + otherCards[index]._star))
                    continue;
                _funcMap.doFightingTo(
                    cardIndex,
                    index,
                    ownerCards,
                    otherCards,
                    AutoChessEntryFunc.stage.effect
                );
                return;
            }
        }
        if (cardTypesId == 3 && pipType == AutoChessEntryFunc.stage.destory) {
            // 当己方卡组中单位被摧毁时，给予对方一个单位造成此卡星级*2的伤害，此效果只会触发一次
            if (ownerCards[cardIndex]._isEffects) return;
            ownerCards[cardIndex]._isEffects = true;
            ownerCards[cardIndex]._cardAttributes[0] =
                ownerCards[cardIndex]._star *
                2;
            for (uint8 index = 0; index < otherCards.length; index++) {
                if (
                    otherCards[index]._cardTypes[0] == 1 &&
                    !otherCards[index]._isDestory
                ) {
                    _funcMap.doFightingTo(
                        cardIndex,
                        index,
                        ownerCards,
                        otherCards,
                        AutoChessEntryFunc.stage.effect
                    );
                }
            }
        }
    }

    function charge(
        uint256 cardIndex,
        uint256,
        AutoChessEntryFunc.stage pipType,
        AutoChessEntryFunc.CardInstance[] memory ownerCards,
        AutoChessEntryFunc.CardInstance[] memory otherCards,
        uint256
    ) private {
        uint256 cardTypesId = ownerCards[cardIndex]._cardTypes[0];
        if (cardTypesId == 1 && pipType == AutoChessEntryFunc.stage.init) {
            ownerCards[cardIndex]._cardAttributes[0] +=
                ownerCards[cardIndex]._star *
                1;
            ownerCards[cardIndex]._cardAttributes[1] += ownerCards[cardIndex]
                ._star;
        }
        if (cardTypesId == 1 && pipType == AutoChessEntryFunc.stage.fighting2) {
            // 额外追加一次攻击
            _funcMap.doFightingOne(cardIndex, ownerCards, otherCards);
            emit chargeEvent(cardIndex, ownerCards[cardIndex]);
        }
        if (cardTypesId == 2) {
            // 点数>3时，使生命值最高的友军对生命值最低的敌军进行一次攻击
            uint256 rand = random(6);
            if (rand > 3) {
                uint256 max = 0;
                uint256 maxIndex = 0;
                for (uint256 index = 0; index < ownerCards.length; index++) {
                    if (
                        ownerCards[index]._cardAttributes[1] > max &&
                        !ownerCards[index]._isDestory
                    ) {
                        max = ownerCards[index]._cardAttributes[1];
                        maxIndex = index;
                    }
                }
                if (max == 0) {
                    return;
                }
                uint256 low = 999999;
                uint256 lowIndex = 9999;
                for (uint8 index = 0; index < otherCards.length; index++) {
                    if (
                        otherCards[index]._cardAttributes[1] < low &&
                        !otherCards[index]._isDestory
                    ) {
                        low = otherCards[index]._cardAttributes[1];
                        lowIndex = index;
                    }
                }
                if (lowIndex == 9999) return;
                _funcMap.doFightingTo(
                    maxIndex,
                    lowIndex,
                    ownerCards,
                    otherCards,
                    AutoChessEntryFunc.stage.effect
                );
                emit chargeEvent(cardIndex, ownerCards[cardIndex]);
            }
        }
        if (cardTypesId == 3) {
            // 对对方所有单位造成此卡星级*1的伤害
            for (uint8 index = 0; index < otherCards.length; index++) {
                if (
                    otherCards[index]._cardTypes[0] == 1 &&
                    !otherCards[index]._isDestory
                ) {
                    ownerCards[cardIndex]._cardAttributes[0] = ownerCards[
                        cardIndex
                    ]._star;
                    _funcMap.doFightingTo(
                        cardIndex,
                        index,
                        ownerCards,
                        otherCards,
                        AutoChessEntryFunc.stage.effect
                    );
                }
            }
            emit chargeEvent(cardIndex, ownerCards[cardIndex]);
        }
    }

    function heroic(
        uint256 cardIndex,
        uint256,
        AutoChessEntryFunc.stage pipType,
        AutoChessEntryFunc.CardInstance[] memory ownerCards,
        AutoChessEntryFunc.CardInstance[] memory,
        uint256
    ) private {
        uint256 cardTypesId = ownerCards[cardIndex]._cardTypes[0];
        if (cardTypesId == 1 && pipType == AutoChessEntryFunc.stage.init) {
            ownerCards[cardIndex]._cardAttributes[0] +=
                ownerCards[cardIndex]._star *
                2;
            ownerCards[cardIndex]._cardAttributes[1] += ownerCards[cardIndex]
                ._star;
            emit heroicEvent(cardIndex, ownerCards[cardIndex]);
        }
        if (pipType == AutoChessEntryFunc.stage.init) return;
        if (cardTypesId == 2) {
            // 己方所有当前单位上升掷点数值的攻击力
            uint256 rand = random(6);
            for (uint256 index = 0; index < ownerCards.length; index++) {
                ownerCards[index]._cardAttributes[0] += rand;
            }
        }
        if (cardTypesId == 3) {
            // 己方所有单位的防御力上升此卡星级*1的数值
            for (uint256 index = 0; index < ownerCards.length; index++) {
                ownerCards[index]._cardAttributes[1] += ownerCards[cardIndex]
                    ._star;
            }
        }
        emit heroicEvent(cardIndex, ownerCards[cardIndex]);
    }
}
